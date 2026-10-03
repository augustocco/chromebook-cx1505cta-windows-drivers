# SPDX-License-Identifier: GPL-2.0-only
"""
Convierte una topología SOF (IPC3) en la secuencia de mensajes IPC que hay
que mandar al DSP para montar las pipelines, más una tabla de PCMs.

Sigue lo que hace Linux en sound/soc/sof/topology.c, ipc3-topology.c y
sof-audio.c (sof_ipc3_set_up_all_pipelines) para pipelines estáticas.

Formato de salida (little endian):
  cabecera  : magic 'SIPC', version, num_pcms, num_msgs
  pcms      : num_pcms x { pcm_id, host_comp_id[2], pipeline_comp_id[2],
                           dai_comp_id[2], name[32] }   (0xFFFFFFFF = no hay)
  mensajes  : num_msgs x { size, bytes[size] } (size múltiplo de 4)

Uso:
  python tplg2ipc.py entrada.tplg salida.bin [--pipelines 1,2,3,10]
                     [--keep-demux] [--multicore] [--list]
"""

import argparse
import struct
import sys

from tplg_parse import Topology, DAPM_NAMES
from sof_tokens import NAMES as TK

NONE_ID = 0xFFFFFFFF

# IPC3 commands (include/sound/sof/header.h)
def GLB(x): return x << 28
def CMD(x): return x << 16

GLB_TPLG = GLB(3)
GLB_COMP = GLB(5)
GLB_DAI = GLB(8)
TPLG_COMP_NEW = CMD(0x001)
TPLG_COMP_CONNECT = CMD(0x003)
TPLG_PIPE_NEW = CMD(0x010)
TPLG_PIPE_COMPLETE = CMD(0x013)
TPLG_BUFFER_NEW = CMD(0x020)
COMP_SET_VALUE = CMD(0x001)
DAI_CONFIG = CMD(0x001)

# enum sof_comp_type
COMP_HOST, COMP_DAI, COMP_VOLUME, COMP_BUFFER, COMP_DEMUX = 1, 2, 5, 12, 18
# enum sof_ipc_dai_type
DAI_TYPES = {"SSP": 1, "DMIC": 2, "HDA": 3, "ALH": 4}
FRAME_FMT = {"s16le": 0, "s24le": 1, "s32le": 2, "float": 3}
PROCESS_TYPES = {"EQFIR": 1, "EQIIR": 2, "KEYWORD_DETECT": 3, "KPB": 4,
                 "CHAN_SELECTOR": 5, "MUX": 6, "DEMUX": 7, "DCBLOCK": 8,
                 "SMART_AMP": 9}
PROCESS_COMP = {7: COMP_DEMUX, 6: 17}

DAI_CONFIG_SIZE = 216          # sizeof(struct sof_ipc_dai_config)
VOL_ZERO_DB = 1 << 16
VOLUME_FWL = 16
VOL_TWENTIETH_ROOT_OF_TEN = 73533
VOL_FORTIETH_ROOT_OF_TEN = 69419

# DAPM ids
AIF_IN, AIF_OUT, DAI_IN, DAI_OUT, BUFFER, SCHED, PGA, EFFECT = 11, 12, 13, 14, 16, 17, 4, 18
VIRTUAL = (0, 1, 5)            # input, output, out_drv


def tok(w, name, default=None):
    t = TK[name]
    for _, k, v in w["tuples"]:
        if k == t:
            return v
    return default


def tok_all(tuples, name):
    t = TK[name]
    return [v for _, k, v in tuples if k == t]


def cmd_hdr(size, cmd):
    return struct.pack("<II", size, cmd)


def comp_hdr(size, comp_id, ctype, pipeline_id, core, ext_len):
    # struct sof_ipc_comp
    return cmd_hdr(size, GLB_TPLG | TPLG_COMP_NEW) + struct.pack(
        "<IIIII", comp_id, ctype, pipeline_id, core, ext_len)


def comp_config(w):
    # struct sof_ipc_comp_config (36 bytes)
    fmt = FRAME_FMT.get(tok(w, "SOF_TKN_COMP_FORMAT", "s16le"), 0)
    return struct.pack("<IIIIIIIII", 36, 0,
                       tok(w, "SOF_TKN_COMP_PERIOD_SINK_COUNT", 0),
                       tok(w, "SOF_TKN_COMP_PERIOD_SOURCE_COUNT", 0),
                       0, fmt, 0, 0, 0)


def comp_new(w, ctype, body):
    """sof_comp_alloc: cabecera + cuerpo + UUID como datos extendidos."""
    uuid = tok(w, "SOF_TKN_COMP_UUID")
    ext = uuid.bytes_le if uuid else b""
    size = 28 + len(body) + len(ext)
    return comp_hdr(size, w["comp_id"], ctype, w["pipeline_id"], w["core"],
                    len(ext)) + body + ext


# --- volumen (topology.c vol_compute_gain) ---------------------------------

def vol_shift_64(i, x):
    if x > 32:
        x = 32
    if x == 0:
        return i & 0xFFFFFFFF
    return (((i >> (x - 1)) + 1) >> 1) & 0xFFFFFFFF


def vol_pow32(a, exp, fwl):
    power = 1 << fwl
    if exp == 0:
        return power
    for _ in range(abs(exp)):
        power = vol_shift_64(power * a, fwl)
    if exp > 0:
        return power
    return ((1 << (fwl << 1)) // power) & 0xFFFFFFFF


def vol_compute_gain(value, tlv):
    tmin, tstep, tmute = tlv
    if value == 0 and tmute:
        return 0
    db = tmin + (value * tstep) // 100
    gain = vol_pow32(VOL_TWENTIETH_ROOT_OF_TEN, db, VOLUME_FWL)
    f_step = tstep - (tstep // 100)
    if f_step == 50 and (value & 1):
        gain = vol_shift_64(gain * VOL_FORTIETH_ROOT_OF_TEN, VOLUME_FWL)
    return gain


def c_int(x):
    return x - (1 << 32) if x & 0x80000000 else x


def volume_info(w):
    for k in w["kcontrols"]:
        if k["kind"] != "mixer":
            continue
        tlv_min, tlv_step, tlv_mute = (c_int(v) for v in k["hdr"]["tlv"])
        tlv = (tlv_min // 100 if tlv_min >= 0 else -((-tlv_min) // 100),
               tlv_step & 0xFFFF, 1 if tlv_mute else 0)
        mn, mx = k["min"], k["max"]
        return {"channels": k["num_channels"], "min_step": mn, "max_step": mx,
                "min_value": vol_compute_gain(mn, tlv),
                "max_value": vol_compute_gain(mx, tlv), "tlv": tlv,
                "name": k["hdr"]["name"]}
    return None


# --- mensajes por widget ---------------------------------------------------

def msg_host(w):
    direction = 1 if w["id"] == AIF_OUT else 0
    body = comp_config(w) + struct.pack(
        "<III", direction, 0, tok(w, "SOF_TKN_PCM_DMAC_CONFIG", 0))
    return comp_new(w, COMP_HOST, body)


# Periodo de planificacion forzado por pipeline (us). La de altavoces (1) viene
# con 10 ms: el DSP lee 10 ms de golpe del bufer WaveRT que Windows llena por
# periodos y, si las fases quedan cruzadas (p. ej. tras cambiar de salida),
# lee datos aun no escritos -> sonido aspero/"saturado". Con 1 ms, como la de
# auriculares (2), no pasa. Los buferes internos se escalan en proporcion.
PIPELINE_PERIOD_US = {1: 1000}


def pipeline_scale(w):
    period = PIPELINE_PERIOD_US.get(w["pipeline_id"])
    return period, (period / 10000.0 if period else 1.0)


def msg_buffer(w):
    # struct sof_ipc_buffer: sin UUID
    size = tok(w, "SOF_TKN_BUF_SIZE", 0)
    period, scale = pipeline_scale(w)
    if period:
        size = int(size * scale)
    body = struct.pack("<IIII", size,
                       tok(w, "SOF_TKN_BUF_CAPS", 0),
                       tok(w, "SOF_TKN_BUF_FLAGS", 0), 0)
    size = 28 + len(body)
    return cmd_hdr(size, GLB_TPLG | TPLG_BUFFER_NEW) + struct.pack(
        "<IIIII", w["comp_id"], COMP_BUFFER, w["pipeline_id"], w["core"], 0) + body


def msg_pga(w, vol):
    body = comp_config(w) + struct.pack(
        "<IIIII", vol["channels"], vol["min_value"], vol["max_value"],
        tok(w, "SOF_TKN_VOLUME_RAMP_STEP_TYPE", 0),
        tok(w, "SOF_TKN_VOLUME_RAMP_STEP_MS", 0))
    return comp_new(w, COMP_VOLUME, body)


def msg_volume_value(w, vol, value=VOL_ZERO_DB):
    """sof_ipc3_widget_kcontrol_setup: SOF_IPC_COMP_SET_VALUE a 0 dB."""
    n = vol["channels"]
    # struct sof_ipc_ctrl_data: rhdr(12) comp_id type cmd index buffer(28)
    #   num_elems elems_remaining msg_index reserved[6]
    hdr_size = 12 + 16 + 28 + 12 + 24
    size = hdr_size + 8 * n
    m = struct.pack("<IIi", size, GLB_COMP | COMP_SET_VALUE, 0)
    m += struct.pack("<IIII", w["comp_id"], 1, 0, 0)   # VALUE_CHAN_SET, CMD_VOLUME
    m += struct.pack("<7I", 0, 0, 0, 0, 0, 0, 0)       # sof_ipc_host_buffer
    m += struct.pack("<III", n, 0, 0) + struct.pack("<6I", *([0] * 6))
    for ch in range(n):
        m += struct.pack("<II", ch, value)
    assert len(m) == size
    return m


def msg_dai_comp(w):
    body = comp_config(w) + struct.pack(
        "<IIII", tok(w, "SOF_TKN_DAI_DIRECTION", 0), tok(w, "SOF_TKN_DAI_INDEX", 0),
        DAI_TYPES[tok(w, "SOF_TKN_DAI_TYPE")], 0)
    return comp_new(w, COMP_DAI, body)


def msg_pipe_new(w, sched_comp_id):
    period = PIPELINE_PERIOD_US.get(w["pipeline_id"]) or tok(w, "SOF_TKN_SCHED_PERIOD", 0)
    return cmd_hdr(48, GLB_TPLG | TPLG_PIPE_NEW) + struct.pack(
        "<IIIIIIIIII", w["comp_id"], w["pipeline_id"], sched_comp_id, w["core"],
        period, tok(w, "SOF_TKN_SCHED_PRIORITY", 0),
        tok(w, "SOF_TKN_SCHED_MIPS", 0), tok(w, "SOF_TKN_SCHED_FRAMES", 0), 0,
        tok(w, "SOF_TKN_SCHED_TIME_DOMAIN", 0))


def msg_connect(src, sink):
    return cmd_hdr(16, GLB_TPLG | TPLG_COMP_CONNECT) + struct.pack(
        "<II", src["comp_id"], sink["comp_id"])


def msg_pipe_complete(w):
    return cmd_hdr(12, GLB_TPLG | TPLG_PIPE_COMPLETE) + struct.pack("<I", w["comp_id"])


def dai_format(hw):
    """sof_dai_set_format + formato base del hw_config."""
    fmt = hw["fmt"] & 0x0F
    if hw["bclk_provider"] == 0:       # SND_SOC_TPLG_BCLK_CP: códec provee BCLK
        fmt |= (0 << 12) if hw["fsync_provider"] == 0 else (3 << 12)
    else:
        fmt |= (2 << 12) if hw["fsync_provider"] == 0 else (4 << 12)
    if hw["invert_bclk"]:
        fmt |= (4 << 8) if hw["invert_fsync"] else (3 << 8)
    else:
        fmt |= (2 << 8) if hw["invert_fsync"] else 0
    return fmt


def msg_dai_config(w, link, flags=1):
    """sof_link_ssp_load / sof_link_dmic_load + sof_ipc3_dai_config(HW_PARAMS)."""
    dtype = DAI_TYPES[tok(w, "SOF_TKN_DAI_TYPE")]
    index = tok(w, "SOF_TKN_DAI_INDEX", 0)
    hws = link["hw_configs"]
    cur = 0
    for i, h in enumerate(hws):
        if h["id"] == link["default_hw_config_id"]:
            cur = i
    hw = hws[cur]

    if dtype == 1:   # SSP
        def ssp_tok(name, default=0):
            vals = tok_all(link["tuples"], name)
            return vals[cur] if cur < len(vals) else (vals[0] if vals else default)
        fmt = dai_format(hw)
        params = struct.pack("<IHH", 60, 0, ssp_tok("SOF_TKN_INTEL_SSP_MCLK_ID"))
        params += struct.pack("<IIIIII", hw["mclk_rate"], hw["fsync_rate"], hw["bclk_rate"],
                              hw["tdm_slots"], hw["rx_slots"], hw["tx_slots"])
        params += struct.pack("<IHH", ssp_tok("SOF_TKN_INTEL_SSP_SAMPLE_BITS"),
                              hw["tdm_slot_width"], 0)
        params += struct.pack("<I", hw["mclk_direction"])
        params += struct.pack("<HH", ssp_tok("SOF_TKN_INTEL_SSP_FRAME_PULSE_WIDTH"),
                              ssp_tok("SOF_TKN_INTEL_SSP_TDM_PADDING_PER_SLOT"))
        params += struct.pack("<III", ssp_tok("SOF_TKN_INTEL_SSP_CLKS_CONTROL"),
                              ssp_tok("SOF_TKN_INTEL_SSP_QUIRKS"),
                              ssp_tok("SOF_TKN_INTEL_SSP_BCLK_DELAY"))
        assert len(params) == 60
    elif dtype == 2:  # DMIC
        fmt = hw["fmt"] & 0xFFFF
        t = link["tuples"]
        def one(name, default=0):
            v = tok_all(t, name)
            return v[0] if v else default
        num_pdm = one("SOF_TKN_INTEL_DMIC_NUM_PDM_ACTIVE")
        params = struct.pack("<IIIIII", 164, one("SOF_TKN_INTEL_DMIC_DRIVER_VERSION"),
                             one("SOF_TKN_INTEL_DMIC_CLK_MIN"), one("SOF_TKN_INTEL_DMIC_CLK_MAX"),
                             one("SOF_TKN_INTEL_DMIC_SAMPLE_RATE"), 0)
        params += struct.pack("<HHHH", one("SOF_TKN_INTEL_DMIC_FIFO_WORD_LENGTH"), 0,
                              one("SOF_TKN_INTEL_DMIC_DUTY_MIN"), one("SOF_TKN_INTEL_DMIC_DUTY_MAX"))
        params += struct.pack("<IIII", num_pdm, 0, 0,
                              one("SOF_TKN_INTEL_DMIC_UNMUTE_RAMP_TIME_MS"))
        params += struct.pack("<5I", 0, 0, 0, 0, 0)
        ids = tok_all(t, "SOF_TKN_INTEL_DMIC_PDM_CTRL_ID")
        cols = {n: tok_all(t, n) for n in (
            "SOF_TKN_INTEL_DMIC_PDM_MIC_A_Enable", "SOF_TKN_INTEL_DMIC_PDM_MIC_B_Enable",
            "SOF_TKN_INTEL_DMIC_PDM_POLARITY_A", "SOF_TKN_INTEL_DMIC_PDM_POLARITY_B",
            "SOF_TKN_INTEL_DMIC_PDM_CLK_EDGE", "SOF_TKN_INTEL_DMIC_PDM_SKEW")}
        for i in range(4):
            if i < num_pdm and i < len(ids):
                vals = [cols[n][i] for n in cols]
                params += struct.pack("<IH6H3H", 24, ids[i], *vals, 0, 0, 0)
            else:
                params += bytes(24)
        assert len(params) == 164, len(params)
    else:
        raise ValueError("tipo de DAI %d no soportado" % dtype)

    m = cmd_hdr(DAI_CONFIG_SIZE, GLB_DAI | DAI_CONFIG)
    m += struct.pack("<IIHBB", dtype, index, fmt, 0, flags) + bytes(32)
    m += params
    m += bytes(DAI_CONFIG_SIZE - len(m))
    return m


# --- conversión -------------------------------------------------------------

def build(tplg, pipelines, keep_demux=False, multicore=False, log=print):
    # comp_id en orden de carga, como Linux (sdev->next_comp_id++)
    widgets = []
    for i, w in enumerate(tplg.widgets):
        w = dict(w)
        w["comp_id"] = i
        w["pipeline_id"] = w["index"]
        core = tok(w, "SOF_TKN_SCHED_CORE") if w["id"] == SCHED else tok(w, "SOF_TKN_COMP_CORE_ID", 0)
        w["core"] = (core or 0) if multicore else 0
        widgets.append(w)
    by_name = {w["name"]: w for w in widgets}
    links = {l["name"]: l for l in tplg.links}

    routes = [(r["source"], r["sink"]) for r in tplg.routes]

    selected = [w for w in widgets if w["pipeline_id"] in pipelines and w["id"] not in VIRTUAL]
    if not keep_demux:
        drop = {w["name"] for w in selected if w["id"] == EFFECT and
                tok(w, "SOF_TKN_PROCESS_TYPE") == "DEMUX"}
        for d in list(drop):
            ins = [s for s, k in routes if k == d]
            outs = [k for s, k in routes if s == d]
            # BUF -> DEMUX -> BUF -> DAI  pasa a  BUF -> DAI (misma pipeline)
            for o in outs:
                if by_name[o]["id"] == BUFFER and \
                        by_name[o]["pipeline_id"] == by_name[d]["pipeline_id"]:
                    nxt = [k for s, k in routes if s == o]
                    drop.add(o)
                    for i in ins:
                        for n in nxt:
                            routes.append((i, n))
                            log("  puente: %s -> %s (sin %s)" % (i, n, d))
        selected = [w for w in selected if w["name"] not in drop]
    sel_names = {w["name"] for w in selected}

    msgs = []
    pcm_hosts = {}

    def add(desc, m):
        assert len(m) % 4 == 0, desc
        msgs.append(m)
        log("%3d  %-34s %4d bytes  cmd=0x%08x" % (len(msgs) - 1, desc, len(m),
                                                  struct.unpack_from("<I", m, 4)[0]))

    # 1) widgets: primero el scheduler de cada pipeline, luego sus componentes
    for pid in pipelines:
        pw = [w for w in selected if w["pipeline_id"] == pid]
        for w in [w for w in pw if w["id"] == SCHED]:
            sched = by_name[w["sname"]]
            add("PIPE_NEW %s" % w["name"], msg_pipe_new(w, sched["comp_id"]))
        for w in [w for w in pw if w["id"] != SCHED]:
            kind = w["id"]
            if kind in (AIF_IN, AIF_OUT):
                add("HOST %s" % w["name"], msg_host(w))
                pcm_hosts[w["name"]] = w
            elif kind == BUFFER:
                add("BUFFER %s" % w["name"], msg_buffer(w))
            elif kind == PGA:
                vol = volume_info(w)
                add("VOLUME %s" % w["name"], msg_pga(w, vol))
                add("  SET_VALUE 0dB %s" % w["name"], msg_volume_value(w, vol))
            elif kind in (DAI_IN, DAI_OUT):
                add("DAI %s" % w["name"], msg_dai_comp(w))
                add("  DAI_CONFIG %s" % w["sname"], msg_dai_config(w, links[w["sname"]]))
            elif kind == EFFECT:
                raise NotImplementedError("componente de proceso %s" % w["name"])
            else:
                raise NotImplementedError("widget %s (%s)" % (w["name"], DAPM_NAMES.get(kind)))

    # 2) conexiones: IPC3 solo admite búfer <-> componente
    for s, k in routes:
        if s in sel_names and k in sel_names:
            ws, wk = by_name[s], by_name[k]
            if ws["id"] == BUFFER or wk["id"] == BUFFER:
                add("CONNECT %s -> %s" % (s, k), msg_connect(ws, wk))

    # 3) pipelines completas
    for pid in pipelines:
        for w in selected:
            if w["pipeline_id"] == pid and w["id"] == SCHED:
                add("PIPE_COMPLETE %s" % w["name"], msg_pipe_complete(w))

    # tabla de PCMs
    pcms = []
    for p in tplg.pcms:
        host = [NONE_ID, NONE_ID]
        pipe = [NONE_ID, NONE_ID]
        dai = [NONE_ID, NONE_ID]
        for d, suffix in ((0, "P"), (1, "C")):
            hw = pcm_hosts.get("PCM%d%s" % (p["pcm_id"], suffix))
            if not hw:
                continue
            host[d] = hw["comp_id"]
            for w in selected:
                if w["pipeline_id"] == hw["pipeline_id"]:
                    if w["id"] == SCHED:
                        pipe[d] = w["comp_id"]
                    elif w["id"] in (DAI_IN, DAI_OUT):
                        dai[d] = w["comp_id"]
        if host != [NONE_ID, NONE_ID]:
            pcms.append((p["pcm_id"], host, pipe, dai, p["pcm_name"]))
            log("PCM %-3d %-10s host=%s pipe=%s dai=%s" % (
                p["pcm_id"], p["pcm_name"], host, pipe, dai))
    return msgs, pcms


def write(path, msgs, pcms):
    out = struct.pack("<4sIII", b"SIPC", 1, len(pcms), len(msgs))
    for pcm_id, host, pipe, dai, name in pcms:
        out += struct.pack("<I2I2I2I", pcm_id, *host, *pipe, *dai)
        out += name.encode("ascii")[:31].ljust(32, b"\0")
    for m in msgs:
        out += struct.pack("<I", len(m)) + m
    open(path, "wb").write(out)
    return len(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tplg")
    ap.add_argument("out")
    ap.add_argument("--pipelines", default="1,2,3,10")
    ap.add_argument("--keep-demux", action="store_true")
    ap.add_argument("--multicore", action="store_true")
    a = ap.parse_args()
    t = Topology(a.tplg)
    msgs, pcms = build(t, [int(x) for x in a.pipelines.split(",")],
                       a.keep_demux, a.multicore)
    n = write(a.out, msgs, pcms)
    print("escrito %s: %d mensajes, %d PCMs, %d bytes" % (a.out, len(msgs), len(pcms), n))


if __name__ == "__main__":
    main()
