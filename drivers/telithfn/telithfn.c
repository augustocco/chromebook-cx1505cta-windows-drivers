// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * telithfn.c -- fn key for the Telith (ASUS Chromebook CX15) keyboard.
 *
 * The EC reports the fn key as its own set 1 scancode (0x5E) and does not
 * change the top row while it is held: every top row key always sends its
 * Vivaldi action code (function-row-physmap in the coreboot SSDT). This
 * filter sits between i8042prt and CoolStar's croskeyboard and, while fn is
 * held, turns the 15 top row keys into real F1..F15. The fn key itself is
 * swallowed; everything else passes through untouched.
 *
 * Stack: kbdclass -> croskeyboard -> telithfn -> i8042prt
 */

#include <ntddk.h>
#include <wdf.h>
#include <ntddkbd.h>
#include <kbdmou.h>

#define TELITH_FN_MAKECODE  0x5E

/* function-row-physmap of the Telith, all with the E0 prefix (T1..T15) */
static const USHORT TopRowE0[] = {
	0x6A, 0x67, 0x11, 0x12, 0x13, 0x14, 0x15,   /* back refresh fullscreen overview snapshot bright- bright+ */
	0x27, 0x28, 0x29, 0x1A, 0x1B,               /* dictate dnd accessibility play/pause mic mute */
	0x20, 0x2E, 0x30,                           /* mute vol- vol+ */
};

/* set 1 scancodes of F1..F15 (no prefix) */
static const USHORT FKeys[] = {
	0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44,  /* F1..F10 */
	0x57, 0x58,                                                    /* F11 F12 */
	0x64, 0x65, 0x66,                                              /* F13..F15 */
};

C_ASSERT(ARRAYSIZE(TopRowE0) == ARRAYSIZE(FKeys));

typedef struct _FN_CONTEXT {
	CONNECT_DATA UpperConnectData;   /* croskeyboard's service callback */
	BOOLEAN FnDown;
	ULONG Translated;                /* top row keys whose make went out as F key */
} FN_CONTEXT, *PFN_CONTEXT;

WDF_DECLARE_CONTEXT_TYPE_WITH_NAME(FN_CONTEXT, FnGetContext)

DRIVER_INITIALIZE DriverEntry;
EVT_WDF_DRIVER_DEVICE_ADD FnEvtDeviceAdd;
EVT_WDF_IO_QUEUE_IO_INTERNAL_DEVICE_CONTROL FnEvtInternalDeviceControl;

static int FnTopRowIndex(USHORT MakeCode)
{
	for (int i = 0; i < ARRAYSIZE(TopRowE0); i++) {
		if (TopRowE0[i] == MakeCode)
			return i;
	}
	return -1;
}

/* Runs at DISPATCH_LEVEL from the i8042prt DPC */
static VOID FnServiceCallback(
	_In_ PDEVICE_OBJECT DeviceObject,
	_In_ PKEYBOARD_INPUT_DATA InputDataStart,
	_In_ PKEYBOARD_INPUT_DATA InputDataEnd,
	_Inout_ PULONG InputDataConsumed)
{
	PFN_CONTEXT ctx = FnGetContext(WdfWdmDeviceGetWdfDeviceHandle(DeviceObject));
	PKEYBOARD_INPUT_DATA src, dst = InputDataStart;
	ULONG consumed = 0;

	for (src = InputDataStart; src < InputDataEnd; src++) {
		KEYBOARD_INPUT_DATA data = *src;
		USHORT prefix = data.Flags & (KEY_E0 | KEY_E1);
		BOOLEAN isBreak = (data.Flags & KEY_BREAK) ? TRUE : FALSE;

		if (prefix == 0 && data.MakeCode == TELITH_FN_MAKECODE) {
			ctx->FnDown = !isBreak;
			continue;                       /* Windows has no use for it */
		}

		if (prefix == KEY_E0) {
			int idx = FnTopRowIndex(data.MakeCode);

			if (idx >= 0) {
				ULONG bit = 1UL << idx;

				/* decide on the first make; repeats and the break follow it */
				if (!isBreak && !(ctx->Translated & bit) && ctx->FnDown)
					ctx->Translated |= bit;

				if (ctx->Translated & bit) {
					data.MakeCode = FKeys[idx];
					data.Flags &= ~KEY_E0;
					if (isBreak)
						ctx->Translated &= ~bit;
				}
			}
		}

		*dst++ = data;
	}

	if (dst > InputDataStart) {
		(*(PSERVICE_CALLBACK_ROUTINE)(ULONG_PTR)ctx->UpperConnectData.ClassService)(
			ctx->UpperConnectData.ClassDeviceObject,
			InputDataStart,
			dst,
			&consumed);
	}

	/* everything was either forwarded or dropped on purpose */
	*InputDataConsumed = (ULONG)(InputDataEnd - InputDataStart);
}

VOID FnEvtInternalDeviceControl(
	_In_ WDFQUEUE Queue,
	_In_ WDFREQUEST Request,
	_In_ size_t OutputBufferLength,
	_In_ size_t InputBufferLength,
	_In_ ULONG IoControlCode)
{
	WDFDEVICE device = WdfIoQueueGetDevice(Queue);
	PFN_CONTEXT ctx = FnGetContext(device);
	WDF_REQUEST_SEND_OPTIONS options;
	NTSTATUS status = STATUS_SUCCESS;

	UNREFERENCED_PARAMETER(OutputBufferLength);
	UNREFERENCED_PARAMETER(InputBufferLength);

	switch (IoControlCode) {
	case IOCTL_INTERNAL_KEYBOARD_CONNECT: {
		PCONNECT_DATA connectData;
		size_t length;

		if (ctx->UpperConnectData.ClassService != NULL) {
			status = STATUS_SHARING_VIOLATION;   /* only one connection */
			break;
		}
		status = WdfRequestRetrieveInputBuffer(Request, sizeof(CONNECT_DATA), (PVOID *)&connectData, &length);
		if (!NT_SUCCESS(status))
			break;

		ctx->UpperConnectData = *connectData;
		connectData->ClassDeviceObject = WdfDeviceWdmGetDeviceObject(device);
#pragma warning(disable:4152)
		connectData->ClassService = FnServiceCallback;
#pragma warning(default:4152)
		break;
	}
	case IOCTL_INTERNAL_KEYBOARD_DISCONNECT:
		status = STATUS_NOT_IMPLEMENTED;          /* as in the kbfiltr sample */
		break;
	default:
		break;
	}

	if (!NT_SUCCESS(status)) {
		WdfRequestComplete(Request, status);
		return;
	}

	/* pass everything (including the connect request) down to i8042prt */
	WDF_REQUEST_SEND_OPTIONS_INIT(&options, WDF_REQUEST_SEND_OPTION_SEND_AND_FORGET);
	if (!WdfRequestSend(Request, WdfDeviceGetIoTarget(device), &options)) {
		status = WdfRequestGetStatus(Request);
		WdfRequestComplete(Request, status);
	}
}

NTSTATUS FnEvtDeviceAdd(_In_ WDFDRIVER Driver, _Inout_ PWDFDEVICE_INIT DeviceInit)
{
	WDF_OBJECT_ATTRIBUTES attributes;
	WDF_IO_QUEUE_CONFIG queueConfig;
	WDFDEVICE device;
	WDFQUEUE queue;
	NTSTATUS status;

	UNREFERENCED_PARAMETER(Driver);
	PAGED_CODE();

	WdfFdoInitSetFilter(DeviceInit);
	WdfDeviceInitSetDeviceType(DeviceInit, FILE_DEVICE_KEYBOARD);

	WDF_OBJECT_ATTRIBUTES_INIT_CONTEXT_TYPE(&attributes, FN_CONTEXT);
	status = WdfDeviceCreate(&DeviceInit, &attributes, &device);
	if (!NT_SUCCESS(status))
		return status;

	/* default queue: everything else is forwarded by the framework */
	WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchParallel);
	queueConfig.EvtIoInternalDeviceControl = FnEvtInternalDeviceControl;
	return WdfIoQueueCreate(device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, &queue);
}

NTSTATUS DriverEntry(_In_ PDRIVER_OBJECT DriverObject, _In_ PUNICODE_STRING RegistryPath)
{
	WDF_DRIVER_CONFIG config;

	WDF_DRIVER_CONFIG_INIT(&config, FnEvtDeviceAdd);
	return WdfDriverCreate(DriverObject, RegistryPath, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
}
