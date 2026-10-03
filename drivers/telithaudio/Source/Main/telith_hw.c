// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * telith_hw.c -- real hardware behind the audio endpoints (Telith):
 * boots the Intel SOF DSP (child of sklhdaudbus), loads the topology and
 * talks to the RT5650 codec driver through kernel callback objects.
 */

#include <initguid.h>
#include <ntddk.h>
#include "telith_hw.h"

#define TELITH_FW_NAME      L"sof-adl-n.ri"
#define TELITH_TPLG_NAME    L"sof-adl-rt5650.ipc"
#define TELITH_FILE_MAX     (4 * 1024 * 1024)
#define TELITH_POOL_TAG     'hTlT'

typedef struct _TELITH_HW {
	BOOLEAN Started;
	PDEVICE_OBJECT Pdo;
	PDRIVER_OBJECT DriverObject;
	ADSP_BUS_INTERFACE BusInterface;
	BOOLEAN BusInterfaceReferenced;
	SOF_DSP Dsp;
	ULONG Generation;                    /* +1 on every DSP boot */

	/* sof-adl-n.ri and sof-adl-rt5650.ipc, read once at start */
	PUCHAR Fw;
	ULONG FwSize;
	PUCHAR Tplg;
	ULONG TplgSize;

	PCALLBACK_OBJECT JackCallback;
	PVOID JackCallbackReg;
	volatile LONG JackType;              /* TELITH_JACK_* */
	PTELITH_JACK_NOTIFY JackNotify[TELITH_JACK_SLOTS];
	PVOID JackNotifyContext[TELITH_JACK_SLOTS];
	KSPIN_LOCK JackLock;
} TELITH_HW;

static TELITH_HW g_Hw;

//
// Bus interface (IRP_MN_QUERY_INTERFACE to the sklhdaudbus PDO)
//

static NTSTATUS telith_query_bus_interface(PDEVICE_OBJECT Pdo, PADSP_BUS_INTERFACE BusInterface)
{
	PDEVICE_OBJECT target;
	PIO_STACK_LOCATION stack;
	IO_STATUS_BLOCK ioStatus;
	KEVENT event;
	NTSTATUS status;
	PIRP irp;

	RtlZeroMemory(BusInterface, sizeof(*BusInterface));
	KeInitializeEvent(&event, NotificationEvent, FALSE);

	target = IoGetAttachedDeviceReference(Pdo);
	irp = IoBuildSynchronousFsdRequest(IRP_MJ_PNP, target, NULL, 0, NULL, &event, &ioStatus);
	if (!irp) {
		ObDereferenceObject(target);
		return STATUS_INSUFFICIENT_RESOURCES;
	}

	irp->IoStatus.Status = STATUS_NOT_SUPPORTED;
	stack = IoGetNextIrpStackLocation(irp);
	stack->MinorFunction = IRP_MN_QUERY_INTERFACE;
	stack->Parameters.QueryInterface.InterfaceType = &GUID_ADSP_BUS_INTERFACE;
	stack->Parameters.QueryInterface.Size = sizeof(ADSP_BUS_INTERFACE);
	stack->Parameters.QueryInterface.Version = 1;
	stack->Parameters.QueryInterface.Interface = (PINTERFACE)BusInterface;
	stack->Parameters.QueryInterface.InterfaceSpecificData = NULL;

	status = IoCallDriver(target, irp);
	if (status == STATUS_PENDING) {
		KeWaitForSingleObject(&event, Executive, KernelMode, FALSE, NULL);
		status = ioStatus.Status;
	}
	ObDereferenceObject(target);
	return status;
}

//
// Files from the driver's directory in the driver store
//

static NTSTATUS telith_load_file(PDRIVER_OBJECT DriverObject, PCWSTR Name, PUCHAR* Data, PULONG Size)
{
	HANDLE dirHandle = NULL, fileHandle = NULL;
	OBJECT_ATTRIBUTES attributes;
	IO_STATUS_BLOCK ioStatus;
	FILE_STANDARD_INFORMATION info;
	UNICODE_STRING fileName;
	PUCHAR buffer;
	NTSTATUS status;

	*Data = NULL;
	*Size = 0;

	status = IoGetDriverDirectory(DriverObject, DriverDirectoryImage, 0, &dirHandle);
	if (!NT_SUCCESS(status))
		return status;

	RtlInitUnicodeString(&fileName, Name);
	InitializeObjectAttributes(&attributes, &fileName, OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE, dirHandle, NULL);

	status = ZwCreateFile(&fileHandle, GENERIC_READ | SYNCHRONIZE, &attributes, &ioStatus, NULL,
		FILE_ATTRIBUTE_NORMAL, FILE_SHARE_READ, FILE_OPEN,
		FILE_SYNCHRONOUS_IO_NONALERT | FILE_NON_DIRECTORY_FILE, NULL, 0);
	if (!NT_SUCCESS(status))
		goto out;

	status = ZwQueryInformationFile(fileHandle, &ioStatus, &info, sizeof(info), FileStandardInformation);
	if (!NT_SUCCESS(status))
		goto out;
	if (info.EndOfFile.QuadPart == 0 || info.EndOfFile.QuadPart > TELITH_FILE_MAX) {
		status = STATUS_INVALID_IMAGE_FORMAT;
		goto out;
	}

	/* non-paged: it is used again while resuming, when paging may not work yet */
	buffer = (PUCHAR)ExAllocatePool2(POOL_FLAG_NON_PAGED, (SIZE_T)info.EndOfFile.QuadPart, TELITH_POOL_TAG);
	if (!buffer) {
		status = STATUS_INSUFFICIENT_RESOURCES;
		goto out;
	}

	status = ZwReadFile(fileHandle, NULL, NULL, NULL, &ioStatus, buffer,
		(ULONG)info.EndOfFile.QuadPart, NULL, NULL);
	if (!NT_SUCCESS(status) || ioStatus.Information != (ULONG_PTR)info.EndOfFile.QuadPart) {
		if (NT_SUCCESS(status))
			status = STATUS_END_OF_FILE;
		ExFreePoolWithTag(buffer, TELITH_POOL_TAG);
		goto out;
	}

	*Data = buffer;
	*Size = (ULONG)info.EndOfFile.QuadPart;

out:
	if (fileHandle)
		ZwClose(fileHandle);
	if (dirHandle)
		ZwClose(dirHandle);
	return status;
}

//
// Codec (rt5650.sys) requests and jack notifications
//

NTSTATUS TelithHwCodecRequestEx(_In_ ULONG Command, _Out_opt_ PULONG JackType)
{
	PCALLBACK_OBJECT callback = NULL;
	OBJECT_ATTRIBUTES attributes;
	UNICODE_STRING name;
	TELITH_CODEC_REQUEST req;
	NTSTATUS status;

	PAGED_CODE();

	RtlInitUnicodeString(&name, TELITH_CODEC_CALLBACK_NAME);
	InitializeObjectAttributes(&attributes, &name,
		OBJ_KERNEL_HANDLE | OBJ_OPENIF | OBJ_CASE_INSENSITIVE | OBJ_PERMANENT, NULL, NULL);
	status = ExCreateCallback(&callback, &attributes, TRUE, TRUE);
	if (!NT_SUCCESS(status))
		return status;

	RtlZeroMemory(&req, sizeof(req));
	req.Size = sizeof(req);
	req.Command = Command;
	req.Rate = 48000;
	req.ValidBits = 24;      /* SSP sample_valid_bits from the topology */
	req.SlotWidth = 32;
	req.Channels = 2;
	req.MclkRate = 24576000;
	req.Status = STATUS_NO_CALLBACK_ACTIVE;   /* stays if rt5650.sys is not loaded */

	ExNotifyCallback(callback, &req, NULL);
	ObDereferenceObject(callback);

	if (JackType)
		*JackType = req.JackType;
	return req.Status;
}

NTSTATUS TelithHwCodecRequest(_In_ ULONG Command)
{
	return TelithHwCodecRequestEx(Command, NULL);
}

static VOID telith_set_jack(ULONG JackType)
{
	static const ULONG slotBits[TELITH_JACK_SLOTS] = {
		TELITH_JACK_HEADPHONE,      /* TELITH_JACK_SLOT_HEADPHONE */
		TELITH_JACK_MICROPHONE,     /* TELITH_JACK_SLOT_HEADSETMIC */
	};
	PTELITH_JACK_NOTIFY notify[TELITH_JACK_SLOTS];
	PVOID context[TELITH_JACK_SLOTS];
	ULONG old, changed, i;
	KIRQL irql;

	JackType &= TELITH_JACK_HEADPHONE | TELITH_JACK_MICROPHONE;
	old = (ULONG)InterlockedExchange(&g_Hw.JackType, (LONG)JackType);
	changed = old ^ JackType;
	if (!changed)
		return;

	KeAcquireSpinLock(&g_Hw.JackLock, &irql);
	for (i = 0; i < TELITH_JACK_SLOTS; i++) {
		notify[i] = g_Hw.JackNotify[i];
		context[i] = g_Hw.JackNotifyContext[i];
	}
	KeReleaseSpinLock(&g_Hw.JackLock, irql);

	for (i = 0; i < TELITH_JACK_SLOTS; i++) {
		if ((changed & slotBits[i]) && notify[i])
			notify[i](context[i]);
	}
}

static VOID TelithJackCallback(PVOID Context, PVOID Arg1, PVOID Arg2)
{
	UNREFERENCED_PARAMETER(Context);
	UNREFERENCED_PARAMETER(Arg2);

	telith_set_jack((ULONG)(ULONG_PTR)Arg1);
}

BOOLEAN TelithHwHeadphoneConnected(VOID)
{
	return (g_Hw.JackType & TELITH_JACK_HEADPHONE) ? TRUE : FALSE;
}

BOOLEAN TelithHwHeadsetMicConnected(VOID)
{
	return (g_Hw.JackType & TELITH_JACK_MICROPHONE) ? TRUE : FALSE;
}

VOID TelithHwSetJackNotify(_In_ ULONG Slot, _In_opt_ PTELITH_JACK_NOTIFY Notify, _In_opt_ PVOID Context)
{
	KIRQL irql;

	if (Slot >= TELITH_JACK_SLOTS)
		return;

	KeAcquireSpinLock(&g_Hw.JackLock, &irql);
	g_Hw.JackNotify[Slot] = Notify;
	g_Hw.JackNotifyContext[Slot] = Context;
	KeReleaseSpinLock(&g_Hw.JackLock, irql);
}

//
// Start / stop
//

PSOF_DSP TelithHwDsp(VOID)
{
	return g_Hw.Started ? &g_Hw.Dsp : NULL;
}

ULONG TelithHwGeneration(VOID)
{
	return g_Hw.Generation;
}

PADSP_BUS_INTERFACE TelithHwBus(VOID)
{
	return g_Hw.BusInterfaceReferenced ? &g_Hw.BusInterface : NULL;
}

/*
 * Boot the DSP from the firmware and topology kept in memory. Used at start
 * and on every return to D0 (resume from standby, hibernation, fast startup):
 * the DSP loses its firmware whenever it is powered down.
 */
static NTSTATUS telith_boot_dsp(VOID)
{
	struct sof_ipc_pm_core_config pm;
	NTSTATUS status;

	status = SofDspInit(&g_Hw.Dsp, &g_Hw.BusInterface);
	if (!NT_SUCCESS(status))
		return status;

	status = SofDspBoot(&g_Hw.Dsp, g_Hw.Fw, g_Hw.FwSize);
	if (!NT_SUCCESS(status))
		return status;

	status = SofIpcStart(&g_Hw.Dsp);
	if (!NT_SUCCESS(status))
		goto err_dsp;

	/* sof_ipc3_set_core_state: core 0 */
	RtlZeroMemory(&pm, sizeof(pm));
	pm.hdr.size = sizeof(pm);
	pm.hdr.cmd = SOF_IPC_GLB_PM_MSG | SOF_IPC_PM_CORE_ENABLE;
	pm.enable_mask = TGL_INIT_CORE_MASK;
	status = SofIpcTx(&g_Hw.Dsp, &pm, sizeof(pm), NULL, 0);
	if (!NT_SUCCESS(status))
		goto err_dsp;

	status = SofTplgLoad(&g_Hw.Dsp, g_Hw.Tplg, g_Hw.TplgSize);
	if (!NT_SUCCESS(status))
		goto err_dsp;

	g_Hw.Generation++;
	g_Hw.Started = TRUE;
	return STATUS_SUCCESS;

err_dsp:
	SofDspShutdown(&g_Hw.Dsp);
	return status;
}

/* telithaudio leaves D0: the DSP is powered down and forgets everything */
VOID TelithHwSuspend(VOID)
{
	PAGED_CODE();

	if (!g_Hw.Started)
		return;

	/*
	 * Mute and power down the codec paths (amps first) while the I2S clocks
	 * still run: cutting the clocks under a live amplifier pops. The streams
	 * start them again when they resume.
	 */
	TelithHwCodecRequest(TelithCodecSpeakerStop);
	TelithHwCodecRequest(TelithCodecHeadphoneStop);
	TelithHwCodecRequest(TelithCodecHeadsetMicStop);

	g_Hw.Started = FALSE;   /* streams see a NULL DSP from now on */
	SofDspShutdown(&g_Hw.Dsp);
}

/* telithaudio is back in D0 */
NTSTATUS TelithHwResume(VOID)
{
	NTSTATUS status;

	PAGED_CODE();

	if (g_Hw.Started || !g_Hw.BusInterfaceReferenced || !g_Hw.Fw)
		return STATUS_SUCCESS;

	status = telith_boot_dsp();
	return status;
}

static VOID telith_free_blobs(VOID)
{
	if (g_Hw.Fw) {
		ExFreePoolWithTag(g_Hw.Fw, TELITH_POOL_TAG);
		g_Hw.Fw = NULL;
	}
	if (g_Hw.Tplg) {
		ExFreePoolWithTag(g_Hw.Tplg, TELITH_POOL_TAG);
		g_Hw.Tplg = NULL;
	}
}

NTSTATUS TelithHwStart(_In_ PDEVICE_OBJECT Fdo, _In_ PDEVICE_OBJECT Pdo)
{
	OBJECT_ATTRIBUTES attributes;
	UNICODE_STRING name;
	ULONG jackType = 0, generation;
	NTSTATUS status;

	PAGED_CODE();

	if (g_Hw.Started)
		return STATUS_SUCCESS;

	generation = g_Hw.Generation;   /* keep counting across restarts */
	RtlZeroMemory(&g_Hw, sizeof(g_Hw));
	g_Hw.Generation = generation;
	KeInitializeSpinLock(&g_Hw.JackLock);
	g_Hw.Pdo = Pdo;
	g_Hw.DriverObject = Fdo->DriverObject;

	status = telith_query_bus_interface(Pdo, &g_Hw.BusInterface);
	if (!NT_SUCCESS(status))
		return status;
	g_Hw.BusInterfaceReferenced = TRUE;

	/* firmware and topology stay in memory for every later resume */
	status = telith_load_file(g_Hw.DriverObject, TELITH_FW_NAME, &g_Hw.Fw, &g_Hw.FwSize);
	if (!NT_SUCCESS(status))
		goto err;
	status = telith_load_file(g_Hw.DriverObject, TELITH_TPLG_NAME, &g_Hw.Tplg, &g_Hw.TplgSize);
	if (!NT_SUCCESS(status))
		goto err;

	status = telith_boot_dsp();
	if (!NT_SUCCESS(status))
		goto err;

	/* jack state from the codec driver, then follow its notifications */
	RtlInitUnicodeString(&name, TELITH_JACK_CALLBACK_NAME);
	InitializeObjectAttributes(&attributes, &name,
		OBJ_KERNEL_HANDLE | OBJ_OPENIF | OBJ_CASE_INSENSITIVE | OBJ_PERMANENT, NULL, NULL);
	if (NT_SUCCESS(ExCreateCallback(&g_Hw.JackCallback, &attributes, TRUE, TRUE))) {
		g_Hw.JackCallbackReg = ExRegisterCallback(g_Hw.JackCallback, TelithJackCallback, NULL);
	}
	status = TelithHwCodecRequestEx(TelithCodecGetJackState, &jackType);
	if (NT_SUCCESS(status))
		g_Hw.JackType = (LONG)(jackType & (TELITH_JACK_HEADPHONE | TELITH_JACK_MICROPHONE));

	return STATUS_SUCCESS;

err:
	telith_free_blobs();
	if (g_Hw.BusInterface.InterfaceDereference)
		g_Hw.BusInterface.InterfaceDereference(g_Hw.BusInterface.Context);
	g_Hw.BusInterfaceReferenced = FALSE;
	return status;
}

VOID TelithHwStop(VOID)
{
	PAGED_CODE();

	for (ULONG i = 0; i < TELITH_JACK_SLOTS; i++)
		TelithHwSetJackNotify(i, NULL, NULL);

	if (g_Hw.JackCallbackReg) {
		ExUnregisterCallback(g_Hw.JackCallbackReg);
		g_Hw.JackCallbackReg = NULL;
	}
	if (g_Hw.JackCallback) {
		ObDereferenceObject(g_Hw.JackCallback);
		g_Hw.JackCallback = NULL;
	}

	if (g_Hw.Started) {
		g_Hw.Started = FALSE;
		SofDspShutdown(&g_Hw.Dsp);
	}
	telith_free_blobs();

	if (g_Hw.BusInterfaceReferenced) {
		if (g_Hw.BusInterface.InterfaceDereference)
			g_Hw.BusInterface.InterfaceDereference(g_Hw.BusInterface.Context);
		g_Hw.BusInterfaceReferenced = FALSE;
	}
}
