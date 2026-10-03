// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * Intel cAVS 2.5 (Tiger Lake / Alder Lake) DSP register definitions.
 *
 * Derived from Linux sound/soc/sof/intel/hda.h and include/sound/sof/*.h,
 * Copyright(c) 2017-2018 Intel Corporation (dual BSD-3-Clause / GPL-2.0).
 */

#ifndef __SOF_HW_H
#define __SOF_HW_H

#define BIT(n)                          (1u << (n))

/* PP capability (HDA BAR) */
#define SOF_HDA_REG_PP_PPCTL            0x04
#define SOF_HDA_PPCTL_PIE               BIT(31)
#define SOF_HDA_PPCTL_GPROCEN           BIT(30)

/* HDA controller (BAR0) */
#define SOF_HDA_INTCTL                  0x20
#define HDA_VS_INTEL_LTRP               0x1048
#define HDA_VS_INTEL_LTRP_GB_MASK       0x3F

/* DSP (BAR4) */
#define HDA_DSP_GEN_BASE                0x0
#define HDA_DSP_REG_ADSPCS              (HDA_DSP_GEN_BASE + 0x04)
#define HDA_DSP_REG_ADSPIC              (HDA_DSP_GEN_BASE + 0x08)
#define HDA_DSP_REG_ADSPIS              (HDA_DSP_GEN_BASE + 0x0C)
#define HDA_DSP_ADSPIC_IPC              BIT(0)
#define HDA_DSP_ADSPIS_IPC              BIT(0)

#define HDA_DSP_ADSPCS_CRST_MASK(cm)    ((cm) << 0)
#define HDA_DSP_ADSPCS_CSTALL_MASK(cm)  ((cm) << 8)
#define HDA_DSP_ADSPCS_SPA_MASK(cm)     ((cm) << 16)
#define HDA_DSP_ADSPCS_CPA_MASK(cm)     ((cm) << 24)

/* IPC (cAVS 1.8+) */
#define CNL_DSP_IPC_BASE                0xc0
#define CNL_DSP_REG_HIPCTDR             (CNL_DSP_IPC_BASE + 0x00)
#define CNL_DSP_REG_HIPCTDA             (CNL_DSP_IPC_BASE + 0x04)
#define CNL_DSP_REG_HIPCTDD             (CNL_DSP_IPC_BASE + 0x08)
#define CNL_DSP_REG_HIPCIDR             (CNL_DSP_IPC_BASE + 0x10)
#define CNL_DSP_REG_HIPCIDA             (CNL_DSP_IPC_BASE + 0x14)
#define CNL_DSP_REG_HIPCIDD             (CNL_DSP_IPC_BASE + 0x18)
#define CNL_DSP_REG_HIPCCTL             (CNL_DSP_IPC_BASE + 0x28)

#define CNL_DSP_REG_HIPCIDR_BUSY        BIT(31)
#define CNL_DSP_REG_HIPCIDR_MSG_MASK    0x7FFFFFFF
#define CNL_DSP_REG_HIPCIDA_DONE        BIT(31)
#define CNL_DSP_REG_HIPCIDA_MSG_MASK    0x7FFFFFFF
#define CNL_DSP_REG_HIPCCTL_DONE        BIT(1)
#define CNL_DSP_REG_HIPCCTL_BUSY        BIT(0)
#define CNL_DSP_REG_HIPCTDR_BUSY        BIT(31)
#define CNL_DSP_REG_HIPCTDR_MSG_MASK    0x7FFFFFFF
#define CNL_DSP_REG_HIPCTDA_DONE        BIT(31)
#define CNL_DSP_REG_HIPCTDD_MSG_MASK    0x7FFFFFFF

/* ROM IPC */
#define HDA_DSP_ROM_IPC_CONTROL         0x01000000
#define HDA_DSP_ROM_IPC_PURGE_FW        0x00004000

/* SRAM windows */
#define SRAM_WINDOW_OFFSET(x)           (0x80000 + (x) * 0x20000)
#define HDA_DSP_MBOX_OFFSET             SRAM_WINDOW_OFFSET(0)
#define HDA_DSP_SRAM_REG_ROM_STATUS     (HDA_DSP_MBOX_OFFSET + 0x0)
#define HDA_DSP_SRAM_REG_ROM_ERROR      (HDA_DSP_MBOX_OFFSET + 0x4)
#define HDA_DSP_MBOX_UPLINK_OFFSET      0x81000

/* Firmware status register */
#define FSR_STATE_MASK                  0x00FFFFFF
#define FSR_TO_STATE_CODE(x)            ((x) & FSR_STATE_MASK)
#define FSR_STATE_INIT_DONE             0x1
#define FSR_STATE_FW_ENTERED            0x5

/* SSP (Tiger Lake / Alder Lake) */
#define CNL_SSP_BASE_OFFSET             0x10000
#define SSP_DEV_MEM_SIZE                0x1000
#define TGL_SSP_COUNT                   3
#define SSP_SSC1_OFFSET                 0x4
#define SSP_SET_SCLK_CONSUMER           BIT(25)
#define SSP_SET_SFRM_CONSUMER           BIT(24)
#define SSP_SET_CBP_CFP                 (SSP_SET_SCLK_CONSUMER | SSP_SET_SFRM_CONSUMER)

/* Timeouts */
#define HDA_DSP_REG_POLL_INTERVAL_US    500
#define HDA_DSP_RESET_TIMEOUT_US        50000
#define HDA_DSP_INIT_TIMEOUT_US         500000
#define HDA_DSP_ROM_INIT_TIMEOUT_US     (300 * 1000)
#define HDA_DSP_BASEFW_TIMEOUT_US       3000000
#define HDA_FW_BOOT_ATTEMPTS            3

/* Core masks (tgl_chip_info) */
#define TGL_INIT_CORE_MASK              BIT(0)
#define TGL_HOST_MANAGED_CORES_MASK     BIT(0)

/* Firmware file */
#define SOF_EXT_MAN_MAGIC_NUMBER        0x6e614d58

/* IPC3 */
#define SOF_GLB_TYPE_SHIFT              28
#define SOF_GLB_TYPE_MASK               (0xfUL << SOF_GLB_TYPE_SHIFT)
#define SOF_GLB_TYPE(x)                 ((x) << SOF_GLB_TYPE_SHIFT)
#define SOF_IPC_FW_READY                SOF_GLB_TYPE(0x7U)
#define SOF_IPC_GLB_REPLY               SOF_GLB_TYPE(0x1U)
#define SOF_IPC_GLB_PM_MSG              SOF_GLB_TYPE(0x4U)
#define SOF_CMD_TYPE_SHIFT              16
#define SOF_CMD_TYPE(x)                 ((x) << SOF_CMD_TYPE_SHIFT)
#define SOF_IPC_PM_CORE_ENABLE          SOF_CMD_TYPE(0x007)
#define SOF_IPC_GLB_STREAM_MSG          SOF_GLB_TYPE(0x6U)
#define SOF_IPC_STREAM_PCM_PARAMS       SOF_CMD_TYPE(0x001)
#define SOF_IPC_STREAM_PCM_FREE         SOF_CMD_TYPE(0x003)
#define SOF_IPC_STREAM_TRIG_START       SOF_CMD_TYPE(0x004)
#define SOF_IPC_STREAM_TRIG_STOP        SOF_CMD_TYPE(0x005)
#define SOF_IPC_STREAM_TRIG_PAUSE       SOF_CMD_TYPE(0x006)
#define SOF_IPC_STREAM_TRIG_RELEASE     SOF_CMD_TYPE(0x007)
#define SOF_IPC_FRAME_S32_LE            2
#define SOF_IPC_BUFFER_INTERLEAVED      0
#define SOF_IPC_MAX_CHANNELS            8
#define SOF_IPC_PANIC_MAGIC             0x0dead000
#define SOF_IPC_PANIC_MAGIC_MASK        0x0ffff000
#define SOF_IPC_MSG_MAX_SIZE            384
#define SOF_IPC_TIMEOUT_MS              500

/* ext data after FW_READY */
#define SOF_IPC_EXT_WINDOW              1
#define SOF_IPC_MAX_ELEMS               16
#define SOF_IPC_REGION_DOWNBOX          0
#define SOF_IPC_REGION_UPBOX            1
#define SOF_IPC_REGION_STREAM           4

#include <pshpack1.h>

struct sof_ext_man_header {
	UINT32 magic;
	UINT32 full_size;
	UINT32 header_size;
	UINT32 header_version;
};

#define SOF_EXT_MAN_ELEM_WINDOW         1

struct sof_ext_man_elem_header {
	UINT32 type;
	UINT32 size;
};

struct sof_ipc_hdr {
	UINT32 size;
};

struct sof_ipc_cmd_hdr {
	UINT32 size;
	UINT32 cmd;
};

struct sof_ipc_fw_version {
	struct sof_ipc_hdr hdr;
	UINT16 major;
	UINT16 minor;
	UINT16 micro;
	UINT16 build;
	UINT8 date[12];
	UINT8 time[10];
	UINT8 tag[6];
	UINT32 abi_version;
	UINT32 src_hash;
	UINT32 reserved[3];
};

struct sof_ipc_fw_ready {
	struct sof_ipc_cmd_hdr hdr;
	UINT32 dspbox_offset;
	UINT32 hostbox_offset;
	UINT32 dspbox_size;
	UINT32 hostbox_size;
	struct sof_ipc_fw_version version;
	UINT64 flags;
	UINT32 reserved[4];
};

struct sof_ipc_reply {
	struct sof_ipc_cmd_hdr hdr;
	INT32 error;
};

struct sof_ipc_ext_data_hdr {
	struct sof_ipc_cmd_hdr hdr;
	UINT32 type;
};

struct sof_ipc_window_elem {
	struct sof_ipc_hdr hdr;
	UINT32 type;
	UINT32 id;
	UINT32 flags;
	UINT32 size;
	UINT32 offset;
};

struct sof_ipc_window {
	struct sof_ipc_ext_data_hdr ext_hdr;
	UINT32 num_windows;
	struct sof_ipc_window_elem window[SOF_IPC_MAX_ELEMS];
};

struct sof_ipc_pm_core_config {
	struct sof_ipc_cmd_hdr hdr;
	UINT32 enable_mask;
};

struct sof_ipc_host_buffer {
	struct sof_ipc_hdr hdr;
	UINT32 phy_addr;
	UINT32 pages;
	UINT32 size;
	UINT32 reserved[3];
};

struct sof_ipc_stream_params {
	struct sof_ipc_hdr hdr;
	struct sof_ipc_host_buffer buffer;
	UINT32 direction;
	UINT32 frame_fmt;
	UINT32 buffer_fmt;
	UINT32 rate;
	UINT16 stream_tag;
	UINT16 channels;
	UINT16 sample_valid_bytes;
	UINT16 sample_container_bytes;
	UINT32 host_period_bytes;
	UINT16 no_stream_position;
	UINT8 cont_update_posn;
	UINT8 reserved0;
	INT16 ext_data_length;
	UINT8 reserved[2];
	UINT16 chmap[SOF_IPC_MAX_CHANNELS];
};

struct sof_ipc_pcm_params {
	struct sof_ipc_cmd_hdr hdr;
	UINT32 comp_id;
	UINT32 flags;
	UINT32 reserved[2];
	struct sof_ipc_stream_params params;
};

struct sof_ipc_pcm_params_reply {
	struct sof_ipc_reply rhdr;
	UINT32 comp_id;
	UINT32 posn_offset;
};

struct sof_ipc_stream {
	struct sof_ipc_cmd_hdr hdr;
	UINT32 comp_id;
};

C_ASSERT(sizeof(struct sof_ipc_stream_params) == 84);
C_ASSERT(sizeof(struct sof_ipc_pcm_params) == 108);

#include <poppack.h>

#endif
