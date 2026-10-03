// SPDX-License-Identifier: GPL-2.0-only
/*
 * rt5650.c -- Realtek RT5650 codec driver for Windows (ASUS Chromebook CX15 "Telith")
 *
 * Register programming derived from the Linux rt5645 ALSA SoC driver,
 * Copyright 2013 Realtek Semiconductor Corp., Author: Bard Liao.
 */

#include "rt5650.h"
#include <gpio.h>
#include <ntstrsafe.h>
#define RESHUB_USE_HELPER_ROUTINES
#include <reshub.h>

static void msleep(ULONG ms)
{
	LARGE_INTEGER interval;
	interval.QuadPart = -10 * 1000 * (LONGLONG)ms;
	KeDelayExecutionThread(KernelMode, FALSE, &interval);
}

//
// Register access. RT5645/RT5650 use 8-bit register addresses with 16-bit
// big-endian values. Registers at RT5645_PR_BASE and above are private
// registers reached through the index/data window.
//

static NTSTATUS rt5650_raw_write(PRT5650_CONTEXT pDevice, UINT8 reg, UINT16 data)
{
	const UINT8 msg[3] = { reg, (UINT8)(data >> 8), (UINT8)data };

	return RtI2cWrite(&pDevice->I2c, msg, sizeof(msg));
}

static NTSTATUS rt5650_raw_read(PRT5650_CONTEXT pDevice, UINT8 reg, UINT16* data)
{
	UINT8 value[2] = { 0, 0 };
	NTSTATUS status;

	status = RtI2cWriteRead(&pDevice->I2c, &reg, sizeof(reg), value, sizeof(value));
	*data = (UINT16)((value[0] << 8) | value[1]);
	return status;
}

static NTSTATUS rt5650_reg_write(PRT5650_CONTEXT pDevice, UINT16 reg, UINT16 data)
{
	if (reg >= RT5645_PR_BASE) {
		NTSTATUS status = rt5650_raw_write(pDevice, RT5645_PRIV_INDEX, reg - RT5645_PR_BASE);
		if (!NT_SUCCESS(status))
			return status;
		return rt5650_raw_write(pDevice, RT5645_PRIV_DATA, data);
	}
	return rt5650_raw_write(pDevice, (UINT8)reg, data);
}

static NTSTATUS rt5650_reg_read(PRT5650_CONTEXT pDevice, UINT16 reg, UINT16* data)
{
	if (reg >= RT5645_PR_BASE) {
		NTSTATUS status = rt5650_raw_write(pDevice, RT5645_PRIV_INDEX, reg - RT5645_PR_BASE);
		if (!NT_SUCCESS(status))
			return status;
		return rt5650_raw_read(pDevice, RT5645_PRIV_DATA, data);
	}
	return rt5650_raw_read(pDevice, (UINT8)reg, data);
}

static NTSTATUS rt5650_reg_update(
	_In_ PRT5650_CONTEXT pDevice,
	UINT16 reg,
	UINT16 mask,
	UINT16 val
) {
	UINT16 tmp = 0, orig = 0;

	NTSTATUS status = rt5650_reg_read(pDevice, reg, &orig);
	if (!NT_SUCCESS(status)) {
		return status;
	}

	tmp = orig & ~mask;
	tmp |= val & mask;

	if (tmp != orig) {
		status = rt5650_reg_write(pDevice, reg, tmp);
	}
	return status;
}

static NTSTATUS rt5650_reg_burstWrite(PRT5650_CONTEXT pDevice, const struct reg* regs, int regCount) {
	NTSTATUS status = STATUS_SUCCESS;
	for (int i = 0; i < regCount; i++) {
		status = rt5650_reg_write(pDevice, regs[i].reg, regs[i].val);
		if (!NT_SUCCESS(status)) {
			return status;
		}
	}
	return status;
}

//
// cbj-sleeve GPIO (output only, from the codec's _CRS)
//

static NTSTATUS rt5650_sleeve_open(PRT5650_CONTEXT pDevice)
{
	WDF_OBJECT_ATTRIBUTES attributes;
	WDF_IO_TARGET_OPEN_PARAMS openParams;
	UNICODE_STRING devicePath;
	WCHAR devicePathBuffer[RESOURCE_HUB_PATH_SIZE];
	NTSTATUS status;

	if (pDevice->GpioIoCount == 0)
		return STATUS_SUCCESS;

	RtlInitEmptyUnicodeString(&devicePath, devicePathBuffer, sizeof(devicePathBuffer));
	status = RESOURCE_HUB_CREATE_PATH_FROM_ID(&devicePath,
		pDevice->SleeveGpioId.LowPart,
		pDevice->SleeveGpioId.HighPart);
	if (!NT_SUCCESS(status))
		return status;

	WDF_OBJECT_ATTRIBUTES_INIT(&attributes);
	attributes.ParentObject = pDevice->FxDevice;

	status = WdfIoTargetCreate(pDevice->FxDevice, &attributes, &pDevice->SleeveGpioTarget);
	if (!NT_SUCCESS(status))
		return status;

	WDF_IO_TARGET_OPEN_PARAMS_INIT_OPEN_BY_NAME(&openParams, &devicePath, GENERIC_READ | GENERIC_WRITE);
	status = WdfIoTargetOpen(pDevice->SleeveGpioTarget, &openParams);
	if (!NT_SUCCESS(status)) {
		WdfObjectDelete(pDevice->SleeveGpioTarget);
		pDevice->SleeveGpioTarget = NULL;
	}
	return status;
}

static void rt5650_sleeve_close(PRT5650_CONTEXT pDevice)
{
	if (pDevice->SleeveGpioTarget) {
		WdfIoTargetClose(pDevice->SleeveGpioTarget);
		WdfObjectDelete(pDevice->SleeveGpioTarget);
		pDevice->SleeveGpioTarget = NULL;
	}
}

static NTSTATUS rt5650_sleeve_set(PRT5650_CONTEXT pDevice, UCHAR value)
{
	WDF_MEMORY_DESCRIPTOR inputDescriptor, outputDescriptor;
	UCHAR data = value;

	if (!pDevice->SleeveGpioTarget)
		return STATUS_DEVICE_NOT_READY;

	WDF_MEMORY_DESCRIPTOR_INIT_BUFFER(&inputDescriptor, &data, sizeof(data));
	WDF_MEMORY_DESCRIPTOR_INIT_BUFFER(&outputDescriptor, &data, sizeof(data));

	return WdfIoTargetSendIoctlSynchronously(pDevice->SleeveGpioTarget, NULL,
		IOCTL_GPIO_WRITE_PINS, &inputDescriptor, &outputDescriptor, NULL, NULL);
}

//
// Codec setup (rt5645_i2c_probe / rt5645_probe / set_bias_level(STANDBY))
//

static const struct reg init_list[] = {
	{RT5645_PR_BASE + 0x3d,	0x3600},
	{RT5645_PR_BASE + 0x1c,	0xfd70},
	{RT5645_PR_BASE + 0x20,	0x611f},
	{RT5645_PR_BASE + 0x21,	0x4040},
	{RT5645_PR_BASE + 0x23,	0x0004},
	{RT5645_ASRC_4, 0x0120},
};

static const struct reg rt5650_init_list[] = {
	{0xf6,	0x0100},
	{RT5645_PWR_ANLG1, 0x02},
	{RT5645_IL_CMD3, 0x6728},
	{RT5645_PR_BASE + 0x3a,	0x0000},
	{RT5645_CLSD_OUT_CTRL1, 0x4059},
	{RT5645_GEN_CTRL3, 0x0200},
};

static NTSTATUS rt5650_identify(PRT5650_CONTEXT pDevice)
{
	UINT16 vendorId2 = 0;
	NTSTATUS status;

	status = rt5650_reg_read(pDevice, RT5645_VENDOR_ID2, &vendorId2);
	if (!NT_SUCCESS(status)) {
		RT_LOG("cannot read the device id (0x%08x)", status);
		return status;
	}

	pDevice->DeviceId = vendorId2;

	if (vendorId2 != RT5650_DEVICE_ID) {
		RT_LOG("unexpected device id 0x%04x", vendorId2);
		return STATUS_DEVICE_CONFIGURATION_ERROR;
	}
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_set_bias_standby(PRT5650_CONTEXT pDevice)
{
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
		RT5645_PWR_VREF1 | RT5645_PWR_MB |
		RT5645_PWR_BG | RT5645_PWR_VREF2,
		RT5645_PWR_VREF1 | RT5645_PWR_MB |
		RT5645_PWR_BG | RT5645_PWR_VREF2);
	msleep(10);
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
		RT5645_PWR_FV1 | RT5645_PWR_FV2,
		RT5645_PWR_FV1 | RT5645_PWR_FV2);
	rt5650_reg_write(pDevice, RT5645_DEPOP_M2, 0x1140);
	msleep(40);
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_init(PRT5650_CONTEXT pDevice)
{
	UINT16 val = 0;
	NTSTATUS status;

	status = rt5650_reg_write(pDevice, RT5645_RESET, 0);
	if (!NT_SUCCESS(status))
		return status;

	rt5650_reg_read(pDevice, RT5645_VENDOR_ID, &val);
	pDevice->VersionId = val & 0xff;

	rt5650_reg_write(pDevice, RT5645_AD_DA_MIXER, 0x8080);

	status = rt5650_reg_burstWrite(pDevice, init_list, ARRAYSIZE(init_list));
	if (!NT_SUCCESS(status))
		return status;
	status = rt5650_reg_burstWrite(pDevice, rt5650_init_list, ARRAYSIZE(rt5650_init_list));
	if (!NT_SUCCESS(status))
		return status;

	rt5650_reg_update(pDevice, RT5645_CLSD_OUT_CTRL, 0xc0, 0xc0);

	// No DMICs on the codec (internal mic goes straight to the DSP).

	// Jack detection, jd_mode 2
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL3,
		RT5645_IRQ_CLK_GATE_CTRL, RT5645_IRQ_CLK_GATE_CTRL);
	rt5650_reg_update(pDevice, RT5645_MICBIAS,
		RT5645_IRQ_CLK_INT, RT5645_IRQ_CLK_INT);
	rt5650_reg_update(pDevice, RT5645_IRQ_CTRL2,
		RT5645_IRQ_JD_1_1_EN, RT5645_IRQ_JD_1_1_EN);
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL3,
		RT5645_JD_PSV_MODE, RT5645_JD_PSV_MODE);
	rt5650_reg_update(pDevice, RT5645_HPO_MIXER,
		RT5645_IRQ_PSV_MODE, RT5645_IRQ_PSV_MODE);
	rt5650_reg_update(pDevice, RT5645_MICBIAS,
		RT5645_MIC2_OVCD_EN, RT5645_MIC2_OVCD_EN);
	rt5650_reg_update(pDevice, RT5645_GPIO_CTRL1,
		RT5645_GP1_PIN_IRQ, RT5645_GP1_PIN_IRQ);
	rt5650_reg_update(pDevice, RT5645_A_JD_CTRL1,
		RT5645_JD1_MODE_MASK, RT5645_JD1_MODE_1);

	rt5650_reg_update(pDevice, RT5645_ADDA_CLK1,
		RT5645_I2S_PD1_MASK, RT5645_I2S_PD1_2);

	// rt5645_probe: "JD Power" and "LDO2" stay on for jack detection
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG2, RT5645_PWR_JD1, RT5645_PWR_JD1);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER, RT5645_PWR_LDO2, RT5645_PWR_LDO2);

	rt5650_set_bias_standby(pDevice);

	// rt5645_set_jack_detect with a button jack (RT5650)
	rt5650_reg_update(pDevice, RT5645_GPIO_CTRL1,
		RT5645_GP1_PIN_IRQ, RT5645_GP1_PIN_IRQ);
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL1,
		RT5645_DIG_GATE_CTRL, RT5645_DIG_GATE_CTRL);
	rt5650_reg_update(pDevice, RT5645_DEPOP_M1,
		RT5645_HP_CB_MASK, RT5645_HP_CB_PU);

	return STATUS_SUCCESS;
}

//
// Jack and headset button detection (rt5645_jack_detect_work)
//

static void rt5650_enable_push_button_irq(PRT5650_CONTEXT pDevice, BOOLEAN enable)
{
	UINT16 val = 0;

	if (enable) {
		rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
			RT5645_PWR_ADC_L | RT5645_PWR_ADC_R,
			RT5645_PWR_ADC_L | RT5645_PWR_ADC_R);

		rt5650_reg_update(pDevice, RT5650_4BTN_IL_CMD2,
			RT5645_EN_4BTN_IL_MASK | RT5645_RST_4BTN_IL_MASK,
			RT5645_EN_4BTN_IL_EN | RT5645_RST_4BTN_IL_RST);
		msleep(10);
		rt5650_reg_update(pDevice, RT5650_4BTN_IL_CMD2,
			RT5645_EN_4BTN_IL_MASK | RT5645_RST_4BTN_IL_MASK,
			RT5645_EN_4BTN_IL_EN | RT5645_RST_4BTN_IL_NORM);
		msleep(50);
		rt5650_reg_read(pDevice, RT5645_INT_IRQ_ST, &val);
		rt5650_reg_write(pDevice, RT5645_INT_IRQ_ST, val);
		rt5650_reg_read(pDevice, RT5650_4BTN_IL_CMD1, &val);
		rt5650_reg_write(pDevice, RT5650_4BTN_IL_CMD1, val);
		rt5650_reg_update(pDevice, RT5650_4BTN_IL_CMD1, 0x3, 0x3);
		rt5650_reg_update(pDevice, RT5645_INT_IRQ_ST, 0x8, 0x8);
	}
	else {
		rt5650_reg_update(pDevice, RT5650_4BTN_IL_CMD2, 0x8000, 0x0);
		rt5650_reg_update(pDevice, RT5645_INT_IRQ_ST, 0x8, 0x0);

		rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
			RT5645_PWR_ADC_L | RT5645_PWR_ADC_R, 0);
	}
}

static INT rt5650_jack_detect(PRT5650_CONTEXT pDevice, BOOLEAN jack_insert)
{
	UINT16 val = 0;

	if (jack_insert) {
		rt5650_reg_write(pDevice, RT5645_CHARGE_PUMP, 0x0206);

		// "LDO2" and "Mic Det Power" for jack type detect
		rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
			RT5645_PWR_MB | RT5645_PWR_VREF2,
			RT5645_PWR_MB | RT5645_PWR_VREF2);
		rt5650_reg_update(pDevice, RT5645_PWR_MIXER,
			RT5645_PWR_LDO2, RT5645_PWR_LDO2);
		rt5650_reg_update(pDevice, RT5645_PWR_VOL,
			RT5645_PWR_MIC_DET, RT5645_PWR_MIC_DET);

		rt5650_reg_write(pDevice, RT5645_JD_CTRL3, 0x00f0);
		rt5650_reg_update(pDevice, RT5645_IN1_CTRL2,
			RT5645_CBJ_MN_JD, RT5645_CBJ_MN_JD);
		rt5650_reg_update(pDevice, RT5645_IN1_CTRL1,
			RT5645_CBJ_BST1_EN, RT5645_CBJ_BST1_EN);
		msleep(100);
		rt5650_reg_update(pDevice, RT5645_IN1_CTRL2,
			RT5645_CBJ_MN_JD, 0);

		rt5650_sleeve_set(pDevice, 1);

		msleep(600);
		rt5650_reg_read(pDevice, RT5645_IN1_CTRL3, &val);
		val &= 0x7;

		if (val == 1 || val == 2) {
			pDevice->JackType = SND_JACK_HEADSET;
			rt5650_enable_push_button_irq(pDevice, TRUE);
		}
		else {
			rt5650_enable_push_button_irq(pDevice, FALSE);
			rt5650_reg_update(pDevice, RT5645_PWR_VOL,
				RT5645_PWR_MIC_DET, 0);
			pDevice->JackType = SND_JACK_HEADPHONE;
			rt5650_sleeve_set(pDevice, 0);
		}

		rt5650_reg_write(pDevice, RT5645_CHARGE_PUMP, 0x0e06);

		/* jack out muted the HP output; undo it if playback kept running */
		if (pDevice->HeadphoneActive)
			rt5650_reg_update(pDevice, RT5645_HP_VOL,
				RT5645_L_MUTE | RT5645_R_MUTE, 0);
	}
	else { /* jack out */
		pDevice->JackType = 0;

		rt5650_reg_update(pDevice, RT5645_HP_VOL,
			RT5645_L_MUTE | RT5645_R_MUTE,
			RT5645_L_MUTE | RT5645_R_MUTE);
		rt5650_reg_update(pDevice, RT5645_IN1_CTRL2,
			RT5645_CBJ_MN_JD, RT5645_CBJ_MN_JD);
		rt5650_reg_update(pDevice, RT5645_IN1_CTRL1,
			RT5645_CBJ_BST1_EN, 0);

		rt5650_enable_push_button_irq(pDevice, FALSE);

		rt5650_reg_update(pDevice, RT5645_PWR_VOL,
			RT5645_PWR_MIC_DET, 0);

		rt5650_sleeve_set(pDevice, 0);
	}

	return pDevice->JackType;
}

static void rt5650_notify_jack(PRT5650_CONTEXT pDevice)
{
	if (pDevice->JackCallback)
		ExNotifyCallback(pDevice->JackCallback, (PVOID)(ULONG_PTR)pDevice->JackType, NULL);
}

static void rt5650_jack_detect_work(PRT5650_CONTEXT pDevice)
{
	UINT16 val = 0, irqSt = 0, btn = 0;
	INT oldJackType = pDevice->JackType;

	WdfWaitLockAcquire(pDevice->RegLock, NULL);

	rt5650_reg_read(pDevice, RT5645_INT_IRQ_ST, &irqSt);
	val = irqSt & 0x1000;

	if (!val && pDevice->JackType == 0) { /* jack in */
		rt5650_jack_detect(pDevice, TRUE);
	}
	else if (!val && pDevice->JackType == SND_JACK_HEADSET) {
		/* push button */
		if (irqSt & 0x4) {
			rt5650_reg_read(pDevice, RT5650_4BTN_IL_CMD1, &btn);
			rt5650_reg_write(pDevice, RT5650_4BTN_IL_CMD1, btn);
			btn &= 0xfff0;
			if (btn)
				pDevice->LastButton = btn;
		}
	}
	else if (val) {
		/* jack out */
		rt5650_reg_update(pDevice, RT5645_INT_IRQ_ST, 0x1, 0x0);
		rt5650_jack_detect(pDevice, FALSE);
	}

	WdfWaitLockRelease(pDevice->RegLock);

	if (pDevice->JackType != oldJackType)
		rt5650_notify_jack(pDevice);

}

//
// Headphone playback (AIF1 <- SSP0). Static version of the DAPM path
// AIF1RX -> IF1 DAC -> DAC1 MIX -> A DAC1 Mux(DAC1) -> DAC L1/R1 ->
// HPOVOL MIX(DAC1) -> HPOVOL -> HPO MIX(HPVOL) -> HP amp -> HPOL/HPOR.
//

static void rt5650_hp_amp_power(PRT5650_CONTEXT pDevice, BOOLEAN on)
{
	UINT16 val = 0;
	int i;

	if (on) {
		if (pDevice->HpAmpCount++ > 0)
			return;

		rt5650_reg_write(pDevice, RT5645_DEPOP_M2, 0x3100);
		rt5650_reg_write(pDevice, RT5645_CHARGE_PUMP, 0x0e06);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M1, 0x000d);
		rt5650_reg_write(pDevice, RT5645_PR_BASE + RT5645_HP_DCC_INT1, 0x9f01);
		for (i = 0; i < 20; i++) {
			msleep(1);
			rt5650_reg_read(pDevice, RT5645_PR_BASE + RT5645_HP_DCC_INT1, &val);
			if (!(val & 0x8000))
				break;
		}
		rt5650_reg_update(pDevice, RT5645_DEPOP_M1,
			RT5645_HP_CO_MASK, RT5645_HP_CO_EN);
		rt5650_reg_write(pDevice, RT5645_PR_BASE + 0x3e, 0x7400);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M3, 0x0737);
		rt5650_reg_write(pDevice, RT5645_PR_BASE + RT5645_MAMP_INT_REG2, 0xfc00);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M2, 0x1140);
		rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
			RT5645_PWR_HP_L | RT5645_PWR_HP_R,
			RT5645_PWR_HP_L | RT5645_PWR_HP_R);
		msleep(90);
	}
	else {
		if (pDevice->HpAmpCount <= 0 || --pDevice->HpAmpCount > 0)
			return;

		rt5650_reg_write(pDevice, RT5645_PR_BASE + 0x3e, 0x7400);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M3, 0x0737);
		rt5650_reg_write(pDevice, RT5645_PR_BASE + RT5645_MAMP_INT_REG2, 0xfc00);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M2, 0x1140);
		msleep(100);
		rt5650_reg_write(pDevice, RT5645_DEPOP_M1, 0x0001);
		rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
			RT5645_PWR_HP_L | RT5645_PWR_HP_R, 0);
	}
}

// set_dai_fmt(I2S, NB_NF, codec consumer) + set_sysclk(MCLK) + hw_params + set_tdm_slot
static NTSTATUS rt5650_aif1_hw_params(PRT5650_CONTEXT pDevice, PTELITH_CODEC_REQUEST req)
{
	UINT16 len, width;

	if (req->Rate != 48000 || req->MclkRate != 24576000)
		return STATUS_NOT_SUPPORTED;   // only MCLK = 512 * fs without PLL for now

	switch (req->ValidBits) {
	case 16: len = 0; break;
	case 20: len = 1; break;
	case 24: len = 2; break;
	default: return STATUS_NOT_SUPPORTED;
	}

	switch (req->ValidBits) {
	case 20: width = 1; break;
	case 24: width = 2; break;
	case 32: width = 3; break;
	default: width = 0; break;
	}

	/* system clock straight from MCLK */
	rt5650_reg_update(pDevice, RT5645_GLB_CLK, RT5645_SCLK_SRC_MASK, RT5645_SCLK_SRC_MCLK);

	/* I2S, normal clocks, codec is clock consumer */
	rt5650_reg_update(pDevice, RT5645_I2S1_SDP,
		RT5645_I2S_MS_MASK | (1 << 8) | RT5645_I2S_DF_MASK,
		RT5645_I2S_MS_S);

	/* data length and pre-divider (24.576 MHz = 2 * 256 * 48 kHz) */
	rt5650_reg_update(pDevice, RT5645_I2S1_SDP, RT5650_I2S_DL_MASK, len << RT5650_I2S_DL_SFT);
	rt5650_reg_update(pDevice, RT5645_ADDA_CLK1, RT5645_I2S_PD1_MASK, 1 << RT5645_I2S_PD1_SFT);

	/* 2 slots, no TDM (rt5645_set_tdm_slot with zero masks) */
	rt5650_reg_update(pDevice, RT5645_TDM_CTRL_1, 0x8ff0, (width << 6) | (width << 4));

	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_headphone_start(PRT5650_CONTEXT pDevice, PTELITH_CODEC_REQUEST req)
{
	NTSTATUS status;

	if (pDevice->HeadphoneActive)
		return STATUS_SUCCESS;

	status = rt5650_aif1_hw_params(pDevice, req);
	if (!NT_SUCCESS(status))
		return status;

	/* bias: SND_SOC_BIAS_PREPARE */
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2);
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL1, RT5645_DIG_GATE_CTRL, RT5645_DIG_GATE_CTRL);

	/* supplies, DACs and HPOVOL mixers */
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_I2S1 | RT5645_PWR_DAC_L1 | RT5645_PWR_DAC_R1,
		RT5645_PWR_I2S1 | RT5645_PWR_DAC_L1 | RT5645_PWR_DAC_R1);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2, RT5645_PWR_DAC_S1F, RT5645_PWR_DAC_S1F);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER,
		RT5645_PWR_HM_L | RT5645_PWR_HM_R | RT5645_PWR_LDO2,
		RT5645_PWR_HM_L | RT5645_PWR_HM_R | RT5645_PWR_LDO2);
	rt5650_reg_update(pDevice, RT5645_PWR_VOL,
		RT5645_PWR_HV_L | RT5645_PWR_HV_R | RT5645_PWR_MIC_DET,
		RT5645_PWR_HV_L | RT5645_PWR_HV_R | RT5645_PWR_MIC_DET);
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG2, RT5645_PWR_JD1, RT5645_PWR_JD1);

	/* routing: DAC1 (IF1, A DAC1 = DAC1) -> HPOVOL MIX -> HPO MIX(HPVOL) */
	rt5650_reg_update(pDevice, RT5645_AD_DA_MIXER,
		(1 << RT5645_M_DAC1_L_SFT) | (1 << RT5645_M_DAC1_R_SFT) |
		(0x3 << RT5645_DAC1_L_SEL_SFT) | (0x3 << RT5645_DAC1_R_SEL_SFT), 0);
	rt5650_reg_update(pDevice, RT5650_A_DAC_SOUR,
		(1 << RT5650_A_DAC1_L_IN_SFT) | (1 << RT5650_A_DAC1_R_IN_SFT), 0);
	rt5650_reg_update(pDevice, RT5645_HPOMIXL_CTRL, RT5645_M_DAC1_HV, 0);
	rt5650_reg_update(pDevice, RT5645_HPOMIXR_CTRL, RT5645_M_DAC1_HV, 0);
	rt5650_reg_update(pDevice, RT5645_HPO_MIXER,
		RT5645_M_DAC1_HM | RT5645_M_HPVOL_HM, RT5645_M_DAC1_HM);

	/* HP amp (POST_PMU) and unmute; volume 25/39 as in the UCM (higher crackles) */
	rt5650_hp_amp_power(pDevice, TRUE);
	rt5650_reg_update(pDevice, RT5645_HP_VOL,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE |
		(0x3f << RT5645_L_VOL_SFT) | (0x3f << RT5645_R_VOL_SFT),
		((39 - 25) << RT5645_L_VOL_SFT) | ((39 - 25) << RT5645_R_VOL_SFT));

	pDevice->HeadphoneActive = TRUE;
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_headphone_stop(PRT5650_CONTEXT pDevice)
{
	if (!pDevice->HeadphoneActive)
		return STATUS_SUCCESS;

	rt5650_reg_update(pDevice, RT5645_HP_VOL,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE);
	rt5650_hp_amp_power(pDevice, FALSE);

	rt5650_reg_update(pDevice, RT5645_HPO_MIXER,
		RT5645_M_DAC1_HM | RT5645_M_HPVOL_HM, RT5645_M_DAC1_HM | RT5645_M_HPVOL_HM);
	rt5650_reg_update(pDevice, RT5645_HPOMIXL_CTRL, RT5645_M_DAC1_HV, RT5645_M_DAC1_HV);
	rt5650_reg_update(pDevice, RT5645_HPOMIXR_CTRL, RT5645_M_DAC1_HV, RT5645_M_DAC1_HV);

	rt5650_reg_update(pDevice, RT5645_PWR_VOL, RT5645_PWR_HV_L | RT5645_PWR_HV_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER, RT5645_PWR_HM_L | RT5645_PWR_HM_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2, RT5645_PWR_DAC_S1F, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1, RT5645_PWR_DAC_L1 | RT5645_PWR_DAC_R1, 0);
	if (!pDevice->HeadsetMicActive)   /* AIF1 is shared with the headset mic */
		rt5650_reg_update(pDevice, RT5645_PWR_DIG1, RT5645_PWR_I2S1, 0);

	/* Mic Det Power stays on only for a headset (jack detection owns it) */
	if (pDevice->JackType != SND_JACK_HEADSET)
		rt5650_reg_update(pDevice, RT5645_PWR_VOL, RT5645_PWR_MIC_DET, 0);

	pDevice->HeadphoneActive = FALSE;
	return STATUS_SUCCESS;
}

//
// Speaker playback (AIF2 <- SSP1). Static version of the DAPM path
// AIF2RX -> IF2 DAC -> DAC L2/R2 Mux(IF2) -> Mono DAC MIX -> A DAC2 Mux(Mono) ->
// DAC L2/R2 -> SPK MIX -> SPKVOL -> SPOL/SPOR MIX -> SPK amp (class D).
// Mixer settings follow alsa-ucm-conf codecs/rt5645/EnableSeq.conf.
//

static NTSTATUS rt5650_aif2_hw_params(PRT5650_CONTEXT pDevice, PTELITH_CODEC_REQUEST req)
{
	UINT16 len;

	if (req->Rate != 48000 || req->MclkRate != 24576000)
		return STATUS_NOT_SUPPORTED;

	switch (req->ValidBits) {
	case 16: len = 0; break;
	case 20: len = 1; break;
	case 24: len = 2; break;
	default: return STATUS_NOT_SUPPORTED;
	}

	rt5650_reg_update(pDevice, RT5645_GLB_CLK, RT5645_SCLK_SRC_MASK, RT5645_SCLK_SRC_MCLK);

	/* I2S, normal clocks, codec is clock consumer */
	rt5650_reg_update(pDevice, RT5645_I2S2_SDP,
		RT5645_I2S_MS_MASK | (1 << 8) | RT5645_I2S_DF_MASK,
		RT5645_I2S_MS_S);
	rt5650_reg_update(pDevice, RT5645_I2S2_SDP, RT5650_I2S_DL_MASK, len << RT5650_I2S_DL_SFT);

	/* pre-divider 2 (24.576 MHz = 2 * 256 * 48 kHz), 64 fs frame (bclk_ms) */
	rt5650_reg_update(pDevice, RT5645_ADDA_CLK1,
		RT5645_I2S_BCLK_MS2_MASK | RT5645_I2S_PD2_MASK,
		(((req->SlotWidth * req->Channels) > 32) << RT5645_I2S_BCLK_MS2_SFT) |
		(1 << RT5645_I2S_PD2_SFT));

	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_speaker_start(PRT5650_CONTEXT pDevice, PTELITH_CODEC_REQUEST req)
{
	NTSTATUS status;

	if (pDevice->SpeakerActive)
		return STATUS_SUCCESS;

	status = rt5650_aif2_hw_params(pDevice, req);
	if (!NT_SUCCESS(status))
		return status;

	/* bias: SND_SOC_BIAS_PREPARE */
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2);
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL1, RT5645_DIG_GATE_CTRL, RT5645_DIG_GATE_CTRL);

	/* supplies, DAC2, mono DAC filters, SPK mixers and volumes */
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_I2S2 | RT5645_PWR_DAC_L2 | RT5645_PWR_DAC_R2,
		RT5645_PWR_I2S2 | RT5645_PWR_DAC_L2 | RT5645_PWR_DAC_R2);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2,
		RT5645_PWR_DAC_MF_L | RT5645_PWR_DAC_MF_R,
		RT5645_PWR_DAC_MF_L | RT5645_PWR_DAC_MF_R);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER,
		RT5645_PWR_SM_L | RT5645_PWR_SM_R,
		RT5645_PWR_SM_L | RT5645_PWR_SM_R);
	rt5650_reg_update(pDevice, RT5645_PWR_VOL,
		RT5645_PWR_SV_L | RT5645_PWR_SV_R,
		RT5645_PWR_SV_L | RT5645_PWR_SV_R);

	/* routing: DAC2 <- IF2, unmuted; Mono DAC MIX(DAC2); A DAC2 = Mono DAC Mixer */
	rt5650_reg_update(pDevice, RT5645_DAC_CTRL,
		(0x7 << RT5645_DAC2_L_SEL_SFT) | (0x7 << RT5645_DAC2_R_SEL_SFT) |
		RT5645_M_DAC_L2_VOL | RT5645_M_DAC_R2_VOL,
		(1 << RT5645_DAC2_L_SEL_SFT) | (1 << RT5645_DAC2_R_SEL_SFT));
	rt5650_reg_update(pDevice, RT5645_MONO_DAC_MIXER,
		RT5645_M_DAC_L2_MONO_L | RT5645_M_DAC_R2_MONO_R, 0);
	rt5650_reg_update(pDevice, RT5650_A_DAC_SOUR,
		(1 << RT5650_A_DAC2_L_IN_SFT) | (1 << RT5650_A_DAC2_R_IN_SFT),
		(1 << RT5650_A_DAC2_L_IN_SFT) | (1 << RT5650_A_DAC2_R_IN_SFT));
	rt5650_reg_update(pDevice, RT5645_SPK_L_MIXER, RT5645_M_DAC_L2_SM_L, 0);
	rt5650_reg_update(pDevice, RT5645_SPK_R_MIXER, RT5645_M_DAC_R2_SM_R, 0);
	rt5650_reg_update(pDevice, RT5645_SPO_MIXER,
		RT5645_M_SV_L_SPM_L | RT5645_M_SV_R_SPM_R, 0);
	rt5650_reg_update(pDevice, RT5645_SPK_VOL,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE, 0);

	/* SPK amp (POST_PMU): class D on */
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_CLS_D | RT5645_PWR_CLS_D_R | RT5645_PWR_CLS_D_L,
		RT5645_PWR_CLS_D | RT5645_PWR_CLS_D_R | RT5645_PWR_CLS_D_L);

	pDevice->SpeakerActive = TRUE;
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_speaker_stop(PRT5650_CONTEXT pDevice)
{
	if (!pDevice->SpeakerActive)
		return STATUS_SUCCESS;

	/* SPK amp (PRE_PMD) */
	rt5650_reg_write(pDevice, RT5645_EQ_CTRL2, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_CLS_D | RT5645_PWR_CLS_D_R | RT5645_PWR_CLS_D_L, 0);

	rt5650_reg_update(pDevice, RT5645_SPK_VOL,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE,
		RT5645_L_MUTE | RT5645_VOL_L_MUTE | RT5645_R_MUTE | RT5645_VOL_R_MUTE);
	rt5650_reg_update(pDevice, RT5645_SPO_MIXER,
		RT5645_M_SV_L_SPM_L | RT5645_M_SV_R_SPM_R,
		RT5645_M_SV_L_SPM_L | RT5645_M_SV_R_SPM_R);
	rt5650_reg_update(pDevice, RT5645_SPK_L_MIXER, RT5645_M_DAC_L2_SM_L, RT5645_M_DAC_L2_SM_L);
	rt5650_reg_update(pDevice, RT5645_SPK_R_MIXER, RT5645_M_DAC_R2_SM_R, RT5645_M_DAC_R2_SM_R);

	rt5650_reg_update(pDevice, RT5645_PWR_VOL, RT5645_PWR_SV_L | RT5645_PWR_SV_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER, RT5645_PWR_SM_L | RT5645_PWR_SM_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2, RT5645_PWR_DAC_MF_L | RT5645_PWR_DAC_MF_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_I2S2 | RT5645_PWR_DAC_L2 | RT5645_PWR_DAC_R2, 0);

	pDevice->SpeakerActive = FALSE;
	return STATUS_SUCCESS;
}

//
// Headset mic capture (AIF1 -> SSP0). Static version of the DAPM path
// IN1P (CBJ) -> BST1 -> RECMIX(BST1) -> ADC L/R -> Stereo1 ADC1 Mux(ADC) ->
// Sto1 ADC MIX(ADC1) -> IF_ADC1 -> IF1 ADC -> AIF1TX.
// Mixer settings follow alsa-ucm-conf codecs/rt5645/HSMicEnableSeq.conf and
// the input part of EnableSeq.conf (ADC 55/63, ADC boost 0, IN 27/31).
//

static NTSTATUS rt5650_headset_mic_start(PRT5650_CONTEXT pDevice, PTELITH_CODEC_REQUEST req)
{
	NTSTATUS status;

	if (pDevice->HeadsetMicActive)
		return STATUS_SUCCESS;

	if (!pDevice->HeadphoneActive) {
		status = rt5650_aif1_hw_params(pDevice, req);
		if (!NT_SUCCESS(status))
			return status;
	}

	/* bias: SND_SOC_BIAS_PREPARE */
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG1,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2,
		RT5645_PWR_VREF1 | RT5645_PWR_MB | RT5645_PWR_BG | RT5645_PWR_VREF2 |
		RT5645_PWR_FV1 | RT5645_PWR_FV2);
	rt5650_reg_update(pDevice, RT5645_GEN_CTRL1, RT5645_DIG_GATE_CTRL, RT5645_DIG_GATE_CTRL);

	/* supplies: I2S1, ADCs, stereo1 ADC filter, BST1 (+ JD, Mic Det), RECMIX, LDO2 */
	rt5650_reg_update(pDevice, RT5645_PWR_DIG1,
		RT5645_PWR_I2S1 | RT5645_PWR_ADC_L | RT5645_PWR_ADC_R,
		RT5645_PWR_I2S1 | RT5645_PWR_ADC_L | RT5645_PWR_ADC_R);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2, RT5645_PWR_ADC_S1F, RT5645_PWR_ADC_S1F);
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG2,
		RT5645_PWR_BST1 | RT5645_PWR_JD1, RT5645_PWR_BST1 | RT5645_PWR_JD1);
	rt5650_reg_update(pDevice, RT5645_PWR_MIXER,
		RT5645_PWR_RM_L | RT5645_PWR_RM_R | RT5645_PWR_LDO2,
		RT5645_PWR_RM_L | RT5645_PWR_RM_R | RT5645_PWR_LDO2);
	rt5650_reg_update(pDevice, RT5645_PWR_VOL, RT5645_PWR_MIC_DET, RT5645_PWR_MIC_DET);

	/* routing: RECMIX <- BST1; Stereo1 ADC1 = ADC; Sto1 ADC MIX: ADC1 on, ADC2 off */
	rt5650_reg_update(pDevice, RT5645_REC_L2_MIXER, RT5645_M_BST1_RM_L, 0);
	rt5650_reg_update(pDevice, RT5645_REC_R2_MIXER, RT5645_M_BST1_RM_R, 0);
	rt5650_reg_update(pDevice, RT5645_STO1_ADC_MIXER,
		RT5645_ADC_1_SRC_MASK | RT5645_M_ADC_L1 | RT5645_M_ADC_R1 |
		RT5645_M_ADC_L2 | RT5645_M_ADC_R2,
		RT5645_ADC_1_SRC_ADC | RT5645_M_ADC_L2 | RT5645_M_ADC_R2);

	/* ADC unmuted at 55/63, ADC boost 0/3, IN volume 27/31 (inverted control) */
	rt5650_reg_update(pDevice, RT5645_STO1_ADC_DIG_VOL,
		RT5645_L_MUTE | RT5645_R_MUTE | (0x3f << (RT5645_L_VOL_SFT + 1)) |
		(0x3f << (RT5645_R_VOL_SFT + 1)),
		(55 << (RT5645_L_VOL_SFT + 1)) | (55 << (RT5645_R_VOL_SFT + 1)));
	rt5650_reg_update(pDevice, RT5645_ADC_BST_VOL1, 0xf000, 0);   /* STO1 ADC L/R boost [15:12] */
	rt5650_reg_update(pDevice, RT5645_INL1_INR1_VOL,
		(0x1f << RT5645_INL_VOL_SFT) | (0x1f << RT5645_INR_VOL_SFT),
		((31 - 27) << RT5645_INL_VOL_SFT) | ((31 - 27) << RT5645_INR_VOL_SFT));

	pDevice->HeadsetMicActive = TRUE;
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_headset_mic_stop(PRT5650_CONTEXT pDevice)
{
	if (!pDevice->HeadsetMicActive)
		return STATUS_SUCCESS;

	rt5650_reg_update(pDevice, RT5645_STO1_ADC_DIG_VOL,
		RT5645_L_MUTE | RT5645_R_MUTE, RT5645_L_MUTE | RT5645_R_MUTE);
	rt5650_reg_update(pDevice, RT5645_STO1_ADC_MIXER,
		RT5645_M_ADC_L1 | RT5645_M_ADC_R1, RT5645_M_ADC_L1 | RT5645_M_ADC_R1);
	rt5650_reg_update(pDevice, RT5645_REC_L2_MIXER, RT5645_M_BST1_RM_L, RT5645_M_BST1_RM_L);
	rt5650_reg_update(pDevice, RT5645_REC_R2_MIXER, RT5645_M_BST1_RM_R, RT5645_M_BST1_RM_R);

	rt5650_reg_update(pDevice, RT5645_PWR_MIXER, RT5645_PWR_RM_L | RT5645_PWR_RM_R, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_ANLG2, RT5645_PWR_BST1, 0);
	rt5650_reg_update(pDevice, RT5645_PWR_DIG2, RT5645_PWR_ADC_S1F, 0);
	/* the ADCs stay on for a headset: the button detection uses them */
	if (pDevice->JackType != SND_JACK_HEADSET)
		rt5650_reg_update(pDevice, RT5645_PWR_DIG1, RT5645_PWR_ADC_L | RT5645_PWR_ADC_R, 0);
	if (!pDevice->HeadphoneActive)
		rt5650_reg_update(pDevice, RT5645_PWR_DIG1, RT5645_PWR_I2S1, 0);

	pDevice->HeadsetMicActive = FALSE;
	return STATUS_SUCCESS;
}

//
// Requests from the DSP driver (\Callback\TelithAudioCodecApi)
//

static VOID Rt5650CodecCallback(PVOID context, PVOID arg1, PVOID arg2)
{
	PRT5650_CONTEXT pDevice = (PRT5650_CONTEXT)context;
	PTELITH_CODEC_REQUEST req = (PTELITH_CODEC_REQUEST)arg1;
	NTSTATUS status;

	UNREFERENCED_PARAMETER(arg2);

	if (!req || req->Size != sizeof(TELITH_CODEC_REQUEST))
		return;
	if (KeGetCurrentIrql() != PASSIVE_LEVEL) {
		req->Status = STATUS_INVALID_DEVICE_STATE;
		return;
	}

	WdfWaitLockAcquire(pDevice->RegLock, NULL);
	switch (req->Command) {
	case TelithCodecHeadphoneStart:
		status = rt5650_headphone_start(pDevice, req);
		break;
	case TelithCodecHeadphoneStop:
		status = rt5650_headphone_stop(pDevice);
		break;
	case TelithCodecSpeakerStart:
		status = rt5650_speaker_start(pDevice, req);
		break;
	case TelithCodecSpeakerStop:
		status = rt5650_speaker_stop(pDevice);
		break;
	case TelithCodecGetJackState:
		req->JackType = (ULONG)pDevice->JackType;
		status = STATUS_SUCCESS;
		break;
	case TelithCodecHeadsetMicStart:
		status = rt5650_headset_mic_start(pDevice, req);
		break;
	case TelithCodecHeadsetMicStop:
		status = rt5650_headset_mic_stop(pDevice);
		break;
	default:
		status = STATUS_NOT_SUPPORTED;
		break;
	}
	WdfWaitLockRelease(pDevice->RegLock);

	req->Status = status;
}

static NTSTATUS rt5650_register_callback(PRT5650_CONTEXT pDevice)
{
	OBJECT_ATTRIBUTES attributes;
	UNICODE_STRING name;
	NTSTATUS status;

	RtlInitUnicodeString(&name, TELITH_CODEC_CALLBACK_NAME);
	InitializeObjectAttributes(&attributes, &name,
		OBJ_KERNEL_HANDLE | OBJ_OPENIF | OBJ_CASE_INSENSITIVE | OBJ_PERMANENT, NULL, NULL);

	status = ExCreateCallback(&pDevice->CodecCallback, &attributes, TRUE, TRUE);
	if (!NT_SUCCESS(status))
		return status;

	pDevice->CodecCallbackReg = ExRegisterCallback(pDevice->CodecCallback,
		Rt5650CodecCallback, pDevice);
	if (!pDevice->CodecCallbackReg) {
		ObDereferenceObject(pDevice->CodecCallback);
		pDevice->CodecCallback = NULL;
		return STATUS_NO_CALLBACK_ACTIVE;
	}

	/* jack change notifications towards the audio driver */
	RtlInitUnicodeString(&name, TELITH_JACK_CALLBACK_NAME);
	InitializeObjectAttributes(&attributes, &name,
		OBJ_KERNEL_HANDLE | OBJ_OPENIF | OBJ_CASE_INSENSITIVE | OBJ_PERMANENT, NULL, NULL);
	if (!NT_SUCCESS(ExCreateCallback(&pDevice->JackCallback, &attributes, TRUE, TRUE)))
		pDevice->JackCallback = NULL;

	return STATUS_SUCCESS;
}

static void rt5650_unregister_callback(PRT5650_CONTEXT pDevice)
{
	if (pDevice->CodecCallbackReg) {
		ExUnregisterCallback(pDevice->CodecCallbackReg);
		pDevice->CodecCallbackReg = NULL;
	}
	if (pDevice->CodecCallback) {
		ObDereferenceObject(pDevice->CodecCallback);
		pDevice->CodecCallback = NULL;
	}
	if (pDevice->JackCallback) {
		ObDereferenceObject(pDevice->JackCallback);
		pDevice->JackCallback = NULL;
	}
}

//
// Jack interrupt: the GpioInt from the codec's _CRS. Handled at PASSIVE_LEVEL
// and deferred to a work item, which debounces and reads the codec.
//

static EVT_WDF_WORKITEM rt5650_jack_work_item;
static EVT_WDF_INTERRUPT_ISR rt5650_jack_isr;

static VOID rt5650_jack_work_item(_In_ WDFWORKITEM WorkItem)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext((WDFDEVICE)WdfWorkItemGetParentObject(WorkItem));

	msleep(250);   /* same debounce as rt5645_irq */
	rt5650_jack_detect_work(pDevice);
}

static BOOLEAN rt5650_jack_isr(_In_ WDFINTERRUPT Interrupt, _In_ ULONG MessageId)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext(WdfInterruptGetDevice(Interrupt));

	UNREFERENCED_PARAMETER(MessageId);

	if (pDevice->ConnectInterrupt)
		WdfWorkItemEnqueue(pDevice->JackWorkItem);
	return TRUE;
}

//
// PnP and power
//

static EVT_WDF_DEVICE_PREPARE_HARDWARE rt5650_prepare_hardware;
static EVT_WDF_DEVICE_RELEASE_HARDWARE rt5650_release_hardware;
static EVT_WDF_DEVICE_D0_ENTRY rt5650_d0_entry;
static EVT_WDF_DEVICE_D0_EXIT rt5650_d0_exit;
static EVT_WDF_DRIVER_DEVICE_ADD rt5650_device_add;

/*
 * The codec's _CRS lists, in this order: I2cSerialBus (the codec),
 * GpioInt (jack detect, handled by the framework) and GpioIo (cbj-sleeve).
 */
static NTSTATUS rt5650_parse_resources(PRT5650_CONTEXT pDevice, WDFCMRESLIST Resources)
{
	BOOLEAN haveI2c = FALSE;
	ULONG count = WdfCmResourceListGetCount(Resources);

	pDevice->GpioIoCount = 0;
	pDevice->InterruptCount = 0;

	for (ULONG i = 0; i < count; i++) {
		PCM_PARTIAL_RESOURCE_DESCRIPTOR res = WdfCmResourceListGetDescriptor(Resources, i);
		LARGE_INTEGER id;

		if (res->Type == CmResourceTypeInterrupt) {
			pDevice->InterruptCount++;
			continue;
		}
		if (res->Type != CmResourceTypeConnection)
			continue;

		id.LowPart = res->u.Connection.IdLowPart;
		id.HighPart = (LONG)res->u.Connection.IdHighPart;

		if (res->u.Connection.Class == CM_RESOURCE_CONNECTION_CLASS_SERIAL &&
			res->u.Connection.Type == CM_RESOURCE_CONNECTION_TYPE_SERIAL_I2C) {
			if (!haveI2c)
				pDevice->I2c.ConnectionId = id;
			haveI2c = TRUE;
		}
		else if (res->u.Connection.Class == CM_RESOURCE_CONNECTION_CLASS_GPIO &&
			res->u.Connection.Type == CM_RESOURCE_CONNECTION_TYPE_GPIO_IO) {
			if (pDevice->GpioIoCount++ == 0)
				pDevice->SleeveGpioId = id;
		}
	}

	return haveI2c ? STATUS_SUCCESS : STATUS_RESOURCE_TYPE_NOT_FOUND;
}

static NTSTATUS rt5650_prepare_hardware(_In_ WDFDEVICE FxDevice,
	_In_ WDFCMRESLIST ResourcesRaw, _In_ WDFCMRESLIST ResourcesTranslated)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext(FxDevice);
	NTSTATUS status;

	UNREFERENCED_PARAMETER(ResourcesRaw);

	status = rt5650_parse_resources(pDevice, ResourcesTranslated);
	if (!NT_SUCCESS(status)) {
		RT_LOG("no I2C connection in the resources");
		return status;
	}

	status = RtI2cOpen(FxDevice, &pDevice->I2c);
	if (!NT_SUCCESS(status)) {
		RT_LOG("cannot open the I2C controller (0x%08x)", status);
		return status;
	}

	/* the sleeve GPIO only matters for headsets; carry on without it */
	if (!NT_SUCCESS(rt5650_sleeve_open(pDevice)))
		RT_LOG("cbj-sleeve GPIO not available");

	status = rt5650_register_callback(pDevice);
	if (!NT_SUCCESS(status))
		RT_LOG("cannot register the codec callback (0x%08x)", status);

	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_release_hardware(_In_ WDFDEVICE FxDevice,
	_In_ WDFCMRESLIST ResourcesTranslated)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext(FxDevice);

	UNREFERENCED_PARAMETER(ResourcesTranslated);

	rt5650_unregister_callback(pDevice);
	rt5650_sleeve_close(pDevice);
	RtI2cClose(&pDevice->I2c);
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_d0_entry(_In_ WDFDEVICE FxDevice, _In_ WDF_POWER_DEVICE_STATE PreviousState)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext(FxDevice);
	NTSTATUS status;

	UNREFERENCED_PARAMETER(PreviousState);

	status = rt5650_identify(pDevice);
	if (!NT_SUCCESS(status))
		return status;

	WdfWaitLockAcquire(pDevice->RegLock, NULL);
	/* the codec lost its registers (resume): every path starts powered down */
	pDevice->HeadphoneActive = FALSE;
	pDevice->SpeakerActive = FALSE;
	pDevice->HeadsetMicActive = FALSE;
	pDevice->HpAmpCount = 0;
	status = rt5650_init(pDevice);
	WdfWaitLockRelease(pDevice->RegLock);
	if (!NT_SUCCESS(status))
		return status;

	pDevice->JackType = 0;
	pDevice->ConnectInterrupt = TRUE;

	/* read the initial jack state (rt5645_set_jack_detect calls rt5645_irq) */
	WdfWorkItemEnqueue(pDevice->JackWorkItem);
	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_d0_exit(_In_ WDFDEVICE FxDevice, _In_ WDF_POWER_DEVICE_STATE TargetState)
{
	PRT5650_CONTEXT pDevice = GetDeviceContext(FxDevice);

	UNREFERENCED_PARAMETER(TargetState);

	pDevice->ConnectInterrupt = FALSE;
	WdfWorkItemFlush(pDevice->JackWorkItem);

	/* orderly power down of whatever is still on, to avoid a pop */
	WdfWaitLockAcquire(pDevice->RegLock, NULL);
	rt5650_speaker_stop(pDevice);
	rt5650_headphone_stop(pDevice);
	rt5650_headset_mic_stop(pDevice);
	WdfWaitLockRelease(pDevice->RegLock);

	return STATUS_SUCCESS;
}

static NTSTATUS rt5650_device_add(_In_ WDFDRIVER Driver, _Inout_ PWDFDEVICE_INIT DeviceInit)
{
	WDF_PNPPOWER_EVENT_CALLBACKS pnpPower;
	WDF_OBJECT_ATTRIBUTES attributes;
	WDF_WORKITEM_CONFIG workItem;
	WDF_INTERRUPT_CONFIG interrupt;
	PRT5650_CONTEXT pDevice;
	WDFDEVICE device;
	NTSTATUS status;

	UNREFERENCED_PARAMETER(Driver);
	PAGED_CODE();

	WDF_PNPPOWER_EVENT_CALLBACKS_INIT(&pnpPower);
	pnpPower.EvtDevicePrepareHardware = rt5650_prepare_hardware;
	pnpPower.EvtDeviceReleaseHardware = rt5650_release_hardware;
	pnpPower.EvtDeviceD0Entry = rt5650_d0_entry;
	pnpPower.EvtDeviceD0Exit = rt5650_d0_exit;
	WdfDeviceInitSetPnpPowerEventCallbacks(DeviceInit, &pnpPower);

	WDF_OBJECT_ATTRIBUTES_INIT_CONTEXT_TYPE(&attributes, RT5650_CONTEXT);
	status = WdfDeviceCreate(&DeviceInit, &attributes, &device);
	if (!NT_SUCCESS(status))
		return status;

	pDevice = GetDeviceContext(device);
	pDevice->FxDevice = device;

	status = WdfWaitLockCreate(WDF_NO_OBJECT_ATTRIBUTES, &pDevice->RegLock);
	if (!NT_SUCCESS(status))
		return status;

	WDF_WORKITEM_CONFIG_INIT(&workItem, rt5650_jack_work_item);
	WDF_OBJECT_ATTRIBUTES_INIT(&attributes);
	attributes.ParentObject = device;
	status = WdfWorkItemCreate(&workItem, &attributes, &pDevice->JackWorkItem);
	if (!NT_SUCCESS(status))
		return status;

	/* the GPIO interrupt comes from a controller behind the resource hub:
	 * it must be serviced at PASSIVE_LEVEL */
	WDF_INTERRUPT_CONFIG_INIT(&interrupt, rt5650_jack_isr, NULL);
	interrupt.PassiveHandling = TRUE;
	status = WdfInterruptCreate(device, &interrupt, WDF_NO_OBJECT_ATTRIBUTES, &pDevice->Interrupt);
	if (!NT_SUCCESS(status))
		RT_LOG("cannot create the jack interrupt (0x%08x)", status);
	return status;
}

NTSTATUS DriverEntry(_In_ PDRIVER_OBJECT DriverObject, _In_ PUNICODE_STRING RegistryPath)
{
	WDF_DRIVER_CONFIG config;

	WDF_DRIVER_CONFIG_INIT(&config, rt5650_device_add);
	return WdfDriverCreate(DriverObject, RegistryPath, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
}
