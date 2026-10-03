// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * i2c.c -- minimal I2C access through the SPB framework.
 *
 * The controller is opened through the resource hub path built from the
 * connection id in the device's resources; writes use IRP_MJ_WRITE and
 * register reads a two-entry IOCTL_SPB_EXECUTE_SEQUENCE (write address,
 * repeated start, read), as described in the WDK SPB documentation.
 */

#include <ntddk.h>
#include <wdf.h>
#include <ntstrsafe.h>
#define RESHUB_USE_HELPER_ROUTINES
#include <reshub.h>
#include <spb.h>
#include "i2c.h"

#define RT_I2C_TIMEOUT  WDF_REL_TIMEOUT_IN_MS(500)

NTSTATUS RtI2cOpen(_In_ WDFDEVICE Device, _Inout_ PRT_I2C I2c)
{
	WCHAR pathBuffer[RESOURCE_HUB_PATH_SIZE];
	UNICODE_STRING path;
	WDF_OBJECT_ATTRIBUTES attributes;
	WDF_IO_TARGET_OPEN_PARAMS params;
	NTSTATUS status;

	RtlInitEmptyUnicodeString(&path, pathBuffer, sizeof(pathBuffer));
	status = RESOURCE_HUB_CREATE_PATH_FROM_ID(&path,
		I2c->ConnectionId.LowPart, I2c->ConnectionId.HighPart);
	if (!NT_SUCCESS(status))
		return status;

	WDF_OBJECT_ATTRIBUTES_INIT(&attributes);
	attributes.ParentObject = Device;

	status = WdfWaitLockCreate(&attributes, &I2c->Lock);
	if (!NT_SUCCESS(status))
		return status;

	status = WdfIoTargetCreate(Device, &attributes, &I2c->Target);
	if (!NT_SUCCESS(status))
		goto fail;

	WDF_IO_TARGET_OPEN_PARAMS_INIT_OPEN_BY_NAME(&params, &path,
		FILE_GENERIC_READ | FILE_GENERIC_WRITE);
	status = WdfIoTargetOpen(I2c->Target, &params);
	if (NT_SUCCESS(status))
		return STATUS_SUCCESS;

	WdfObjectDelete(I2c->Target);
	I2c->Target = NULL;
fail:
	WdfObjectDelete(I2c->Lock);
	I2c->Lock = NULL;
	return status;
}

VOID RtI2cClose(_Inout_ PRT_I2C I2c)
{
	if (I2c->Target) {
		WdfIoTargetClose(I2c->Target);
		WdfObjectDelete(I2c->Target);
		I2c->Target = NULL;
	}
	if (I2c->Lock) {
		WdfObjectDelete(I2c->Lock);
		I2c->Lock = NULL;
	}
}

NTSTATUS RtI2cWrite(_In_ PRT_I2C I2c,
	_In_reads_bytes_(Length) const VOID *Data, _In_ ULONG Length)
{
	WDF_MEMORY_DESCRIPTOR memory;
	WDF_REQUEST_SEND_OPTIONS options;
	ULONG_PTR written = 0;
	NTSTATUS status;

	if (!I2c->Target)
		return STATUS_DEVICE_NOT_READY;

	WDF_MEMORY_DESCRIPTOR_INIT_BUFFER(&memory, (PVOID)Data, Length);
	WDF_REQUEST_SEND_OPTIONS_INIT(&options, WDF_REQUEST_SEND_OPTION_TIMEOUT);
	WDF_REQUEST_SEND_OPTIONS_SET_TIMEOUT(&options, RT_I2C_TIMEOUT);

	WdfWaitLockAcquire(I2c->Lock, NULL);
	status = WdfIoTargetSendWriteSynchronously(I2c->Target, NULL, &memory,
		NULL, &options, &written);
	WdfWaitLockRelease(I2c->Lock);

	if (NT_SUCCESS(status) && written != Length)
		status = STATUS_DEVICE_PROTOCOL_ERROR;
	return status;
}

NTSTATUS RtI2cWriteRead(_In_ PRT_I2C I2c,
	_In_reads_bytes_(OutLength) const VOID *Out, _In_ ULONG OutLength,
	_Out_writes_bytes_(InLength) VOID *In, _In_ ULONG InLength)
{
	SPB_TRANSFER_LIST_AND_ENTRIES(2) sequence;
	WDF_MEMORY_DESCRIPTOR memory;
	WDF_REQUEST_SEND_OPTIONS options;
	ULONG_PTR transferred = 0;
	NTSTATUS status;

	if (!I2c->Target)
		return STATUS_DEVICE_NOT_READY;

	SPB_TRANSFER_LIST_INIT(&sequence.List, 2);
	sequence.List.Transfers[0] = SPB_TRANSFER_LIST_ENTRY_INIT_SIMPLE(
		SpbTransferDirectionToDevice, 0, (PVOID)Out, OutLength);
	sequence.List.Transfers[1] = SPB_TRANSFER_LIST_ENTRY_INIT_SIMPLE(
		SpbTransferDirectionFromDevice, 0, In, InLength);

	WDF_MEMORY_DESCRIPTOR_INIT_BUFFER(&memory, &sequence, sizeof(sequence));
	WDF_REQUEST_SEND_OPTIONS_INIT(&options, WDF_REQUEST_SEND_OPTION_TIMEOUT);
	WDF_REQUEST_SEND_OPTIONS_SET_TIMEOUT(&options, RT_I2C_TIMEOUT);

	WdfWaitLockAcquire(I2c->Lock, NULL);
	status = WdfIoTargetSendIoctlSynchronously(I2c->Target, NULL,
		IOCTL_SPB_EXECUTE_SEQUENCE, &memory, NULL, &options, &transferred);
	WdfWaitLockRelease(I2c->Lock);

	/* the IOCTL reports the bytes moved in both directions */
	if (NT_SUCCESS(status) && transferred != (ULONG_PTR)OutLength + InLength)
		status = STATUS_DEVICE_PROTOCOL_ERROR;
	return status;
}
