# SPDX-License-Identifier: GPL-2.0-only
"""
Lector de topologías ALSA/ASoC (.tplg) para SOF IPC3.

Formato según include/uapi/sound/asoc.h de Linux. Solo lee; la conversión a
mensajes IPC3 está en tplg2ipc.py.
"""

import struct
import sys
import uuid as uuidlib

NAME_LEN = 44            # SNDRV_CTL_ELEM_ID_NAME_MAXLEN
TLV_SIZE = 32            # SND_SOC_TPLG_TLV_SIZE
MAX_CHAN = 8
NUM_TEXTS = 16
STREAM_CONFIG_MAX = 8
HW_CONFIG_MAX = 8
MAGIC = 0x41536F43

TYPE_NAMES = {
    1: "MIXER", 2: "BYTES", 3: "ENUM", 4: "DAPM_GRAPH", 5: "DAPM_WIDGET",
    6: "DAI_LINK", 7: "PCM", 8: "MANIFEST", 9: "CODEC_LINK",
    10: "BACKEND_LINK", 11: "PDATA", 12: "DAI",
}

DAPM_NAMES = {
    0: "input", 1: "output", 2: "mux", 3: "mixer", 4: "pga", 5: "out_drv",
    6: "adc", 7: "dac", 8: "switch", 9: "pre", 10: "post", 11: "aif_in",
    12: "aif_out", 13: "dai_in", 14: "dai_out", 15: "dai_link",
    16: "buffer", 17: "scheduler", 18: "effect", 19: "siggen", 20: "src",
    21: "asrc", 22: "encoder", 23: "decoder",
}

TUPLE_UUID, TUPLE_STRING, TUPLE_BOOL, TUPLE_BYTE, TUPLE_WORD, TUPLE_SHORT = range(6)


def cstr(b):
    return b.split(b"\0", 1)[0].decode("ascii", "replace")


class Reader:
    def __init__(self, data, off=0):
        self.d = data
        self.o = off

    def u8(self):
        v = self.d[self.o]
        self.o += 1
        return v

    def u16(self):
        v = struct.unpack_from("<H", self.d, self.o)[0]
        self.o += 2
        return v

    def u32(self):
        v = struct.unpack_from("<I", self.d, self.o)[0]
        self.o += 4
        return v

    def u64(self):
        v = struct.unpack_from("<Q", self.d, self.o)[0]
        self.o += 8
        return v

    def name(self):
        v = cstr(self.d[self.o:self.o + NAME_LEN])
        self.o += NAME_LEN
        return v

    def raw(self, n):
        v = self.d[self.o:self.o + n]
        self.o += n
        return v


def parse_private(r):
    """snd_soc_tplg_private -> (raw bytes, list of (tuple_type, token, value))."""
    size = r.u32()
    start = r.o
    raw = r.raw(size)
    tuples = []
    o = 0
    while o + 12 <= size:
        arr_size, arr_type, num = struct.unpack_from("<III", raw, o)
        if arr_size < 12 or o + arr_size > size:
            break
        e = o + 12
        for _ in range(num):
            if arr_type == TUPLE_UUID:
                tok = struct.unpack_from("<I", raw, e)[0]
                val = uuidlib.UUID(bytes_le=bytes(raw[e + 4:e + 20]))
                e += 20
            elif arr_type == TUPLE_STRING:
                tok = struct.unpack_from("<I", raw, e)[0]
                val = cstr(raw[e + 4:e + 4 + NAME_LEN])
                e += 4 + NAME_LEN
            else:
                tok, val = struct.unpack_from("<II", raw, e)
                e += 8
            tuples.append((arr_type, tok, val))
        o += arr_size
    r.o = start + size
    return bytes(raw), tuples


def parse_ctl_hdr(r):
    start = r.o
    size = r.u32()
    typ = r.u32()
    name = r.name()
    access = r.u32()
    ops = (r.u32(), r.u32(), r.u32())
    tlv_size = r.u32()
    tlv_type = r.u32()
    tlv = [r.u32() for _ in range(TLV_SIZE)]
    r.o = start + size
    return {"type": typ, "name": name, "access": access, "ops": ops,
            "tlv_type": tlv_type, "tlv": tlv[:3]}


def parse_channels(r):
    ch = []
    for _ in range(MAX_CHAN):
        size, reg, shift, cid = r.u32(), r.u32(), r.u32(), r.u32()
        ch.append({"reg": reg, "shift": shift, "id": cid})
    return ch


def parse_mixer(r):
    start = r.o
    hdr = parse_ctl_hdr(r)
    size = r.u32()
    m = {"kind": "mixer", "hdr": hdr, "min": r.u32(), "max": r.u32(),
         "platform_max": r.u32(), "invert": r.u32(), "num_channels": r.u32()}
    m["channels"] = parse_channels(r)[:m["num_channels"]]
    m["priv"], m["tuples"] = parse_private(r)
    return m


def parse_enum(r):
    hdr = parse_ctl_hdr(r)
    size = r.u32()
    e = {"kind": "enum", "hdr": hdr, "num_channels": r.u32()}
    e["channels"] = parse_channels(r)[:e["num_channels"]]
    e["items"], e["mask"], e["count"] = r.u32(), r.u32(), r.u32()
    e["texts"] = [r.name() for _ in range(NUM_TEXTS)][:e["items"]]
    r.raw(NUM_TEXTS * NAME_LEN)  # values
    e["priv"], e["tuples"] = parse_private(r)
    return e


def parse_bytes(r):
    hdr = parse_ctl_hdr(r)
    size = r.u32()
    b = {"kind": "bytes", "hdr": hdr, "max": r.u32(), "mask": r.u32(),
         "base": r.u32(), "num_regs": r.u32(),
         "ext_ops": (r.u32(), r.u32(), r.u32())}
    b["priv"], b["tuples"] = parse_private(r)
    return b


def parse_control_any(r, block_type=None):
    """Widget kcontrols se distinguen por ctl_hdr.type (soc_tplg_dapm_widget_create)."""
    save = r.o
    hdr = parse_ctl_hdr(r)
    r.o = save
    typ = block_type if block_type is not None else hdr["type"]
    if typ == 1:
        return parse_mixer(r)
    if typ == 3:
        return parse_enum(r)
    if typ == 2:
        return parse_bytes(r)
    raise ValueError("tipo de control %d no soportado (%r) en 0x%x" % (typ, hdr["name"], save))


def parse_stream(r):
    size = r.u32()
    s = {"name": r.name(), "format": r.u64(), "rate": r.u32(),
         "period_bytes": r.u32(), "buffer_bytes": r.u32(), "channels": r.u32()}
    return s


def parse_caps(r):
    size = r.u32()
    c = {"name": r.name(), "formats": r.u64(), "rates": r.u32(),
         "rate_min": r.u32(), "rate_max": r.u32(), "channels_min": r.u32(),
         "channels_max": r.u32(), "periods_min": r.u32(), "periods_max": r.u32(),
         "period_size_min": r.u32(), "period_size_max": r.u32(),
         "buffer_size_min": r.u32(), "buffer_size_max": r.u32(),
         "sig_bits": r.u32()}
    return c


def parse_hw_config(r):
    start = r.o
    size = r.u32()
    h = {"id": r.u32(), "fmt": r.u32(), "clock_gated": r.u8(),
         "invert_bclk": r.u8(), "invert_fsync": r.u8(), "bclk_provider": r.u8(),
         "fsync_provider": r.u8(), "mclk_direction": r.u8()}
    r.u16()
    h.update({"mclk_rate": r.u32(), "bclk_rate": r.u32(), "fsync_rate": r.u32(),
              "tdm_slots": r.u32(), "tdm_slot_width": r.u32(),
              "tx_slots": r.u32(), "rx_slots": r.u32()})
    h["tx_channels"] = r.u32()
    h["tx_chanmap"] = [r.u32() for _ in range(MAX_CHAN)]
    h["rx_channels"] = r.u32()
    h["rx_chanmap"] = [r.u32() for _ in range(MAX_CHAN)]
    # el campo size puede venir a 0 en entradas sin usar: el tamaño es fijo (120)
    assert r.o - start == 120
    return h


class Topology:
    def __init__(self, path):
        self.data = open(path, "rb").read()
        self.blocks = []
        self.widgets = []
        self.routes = []
        self.pcms = []
        self.links = []
        self.dais = []
        self.controls = []
        self.manifest = None
        self._parse()

    def _parse(self):
        o = 0
        d = self.data
        while o + 36 <= len(d):
            magic, abi, version, typ, size, vtype, psize, index, count = \
                struct.unpack_from("<9I", d, o)
            if magic != MAGIC:
                raise ValueError("magic incorrecto en 0x%x" % o)
            body = o + size
            self.blocks.append((typ, index, count, psize))
            r = Reader(d, body)
            if typ == 8:
                r.u32()
                self.manifest = [r.u32() for _ in range(6)]
            elif typ == 5:
                for _ in range(count):
                    self.widgets.append(self._widget(r, index))
            elif typ == 4:
                for _ in range(count):
                    sink, ctl, src = r.name(), r.name(), r.name()
                    self.routes.append({"sink": sink, "control": ctl,
                                        "source": src, "index": index})
            elif typ == 7:
                for _ in range(count):
                    self.pcms.append(self._pcm(r))
            elif typ in (6, 10):
                for _ in range(count):
                    self.links.append(self._link(r))
            elif typ == 12:
                for _ in range(count):
                    self.dais.append(self._dai(r))
            elif typ in (1, 2, 3):
                for _ in range(count):
                    c = parse_control_any(r, typ)
                    c["index"] = index
                    self.controls.append(c)
            o = body + psize

    def _widget(self, r, index):
        start = r.o
        size = r.u32()
        w = {"index": index, "id": r.u32(), "name": r.name(), "sname": r.name(),
             "reg": r.u32(), "shift": r.u32(), "mask": r.u32(),
             "subseq": r.u32(), "invert": r.u32(), "ignore_suspend": r.u32(),
             "event_flags": r.u16(), "event_type": r.u16(),
             "num_kcontrols": r.u32()}
        r.o = start + size - 4  # priv.size forma parte de la estructura
        w["priv"], w["tuples"] = parse_private(r)
        w["kcontrols"] = [parse_control_any(r) for _ in range(w["num_kcontrols"])]
        return w

    def _pcm(self, r):
        start = r.o
        size = r.u32()
        p = {"pcm_name": r.name(), "dai_name": r.name(), "pcm_id": r.u32(),
             "dai_id": r.u32(), "playback": r.u32(), "capture": r.u32(),
             "compress": r.u32()}
        p["streams"] = [parse_stream(r) for _ in range(STREAM_CONFIG_MAX)]
        p["num_streams"] = r.u32()
        p["caps"] = [parse_caps(r) for _ in range(2)]
        p["flag_mask"], p["flags"] = r.u32(), r.u32()
        r.o = start + size - 4  # priv.size forma parte de la estructura
        p["priv"], p["tuples"] = parse_private(r)
        return p

    def _link(self, r):
        start = r.o
        size = r.u32()
        l = {"id": r.u32(), "name": r.name(), "stream_name": r.name()}
        l["streams"] = [parse_stream(r) for _ in range(STREAM_CONFIG_MAX)]
        l["num_streams"] = r.u32()
        l["hw_configs"] = [parse_hw_config(r) for _ in range(HW_CONFIG_MAX)]
        l["num_hw_configs"] = r.u32()
        l["default_hw_config_id"] = r.u32()
        l["flag_mask"], l["flags"] = r.u32(), r.u32()
        r.o = start + size - 4  # priv.size forma parte de la estructura
        l["priv"], l["tuples"] = parse_private(r)
        l["hw_configs"] = l["hw_configs"][:l["num_hw_configs"]]
        return l

    def _dai(self, r):
        start = r.o
        size = r.u32()
        dname = r.name()
        dai = {"dai_name": dname, "dai_id": r.u32(), "playback": r.u32(),
               "capture": r.u32()}
        dai["caps"] = [parse_caps(r) for _ in range(2)]
        dai["flag_mask"], dai["flags"] = r.u32(), r.u32()
        r.o = start + size - 4  # priv.size forma parte de la estructura
        dai["priv"], dai["tuples"] = parse_private(r)
        return dai


if __name__ == "__main__":
    from sof_tokens import token_name
    t = Topology(sys.argv[1])
    print("manifest:", t.manifest)
    print("blocks:", [(TYPE_NAMES.get(b[0], b[0]), b[1], b[2]) for b in t.blocks])
    for w in t.widgets:
        print("\nWIDGET [%d] %-10s %-28s sname=%r kctl=%d" % (
            w["index"], DAPM_NAMES.get(w["id"], w["id"]), w["name"], w["sname"],
            w["num_kcontrols"]))
        for typ, tok, val in w["tuples"]:
            print("    %-36s %s" % (token_name(tok), val))
        for k in w["kcontrols"]:
            print("    kcontrol %s %r" % (k["kind"], k["hdr"]["name"]))
    print()
    for rt in t.routes:
        print("ROUTE [%d] %s -> %s%s" % (rt["index"], rt["source"], rt["sink"],
                                         (" (%s)" % rt["control"]) if rt["control"] else ""))
    for p in t.pcms:
        print("\nPCM %d %r dai=%r pb=%d cap=%d" % (p["pcm_id"], p["pcm_name"],
                                                   p["dai_name"], p["playback"], p["capture"]))
        for typ, tok, val in p["tuples"]:
            print("    %-36s %s" % (token_name(tok), val))
    for l in t.links:
        print("\nLINK %d %r stream=%r hw_configs=%d default=%d" % (
            l["id"], l["name"], l["stream_name"], l["num_hw_configs"],
            l["default_hw_config_id"]))
        for h in l["hw_configs"]:
            print("    hw %d fmt=0x%x bclk_p=%d fsync_p=%d mclk=%d bclk=%d fs=%d slots=%d width=%d tx=0x%x rx=0x%x" % (
                h["id"], h["fmt"], h["bclk_provider"], h["fsync_provider"],
                h["mclk_rate"], h["bclk_rate"], h["fsync_rate"], h["tdm_slots"],
                h["tdm_slot_width"], h["tx_slots"], h["rx_slots"]))
        for typ, tok, val in l["tuples"]:
            print("    %-36s %s" % (token_name(tok), val))
    for c in t.controls:
        print("\nCONTROL [%d] %s %r" % (c["index"], c["kind"], c["hdr"]["name"]))
