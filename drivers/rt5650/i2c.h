// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * i2c.h -- minimal I2C access through the SPB framework (resource hub
 * connection taken from the device's _CRS).
 */

#ifndef _RT5650_I2C_H_
#define _RT5650_I2C_H_

#include <wdf.h>

typedef struct _RT_I2C {
	LARGE_INTEGER ConnectionId;   /* CmResourceTypeConnection, SERIAL_I2C */
	WDFIOTARGET Target;
	WDFWAITLOCK Lock;             /* one transfer at a time */
} RT_I2C, *PRT_I2C;

NTSTATUS RtI2cOpen(_In_ WDFDEVICE Device, _Inout_ PRT_I2C I2c);
VOID RtI2cClose(_Inout_ PRT_I2C I2c);

/* plain write */
NTSTATUS RtI2cWrite(_In_ PRT_I2C I2c,
	_In_reads_bytes_(Length) const VOID *Data, _In_ ULONG Length);

/* write then read with a repeated start (register read) */
NTSTATUS RtI2cWriteRead(_In_ PRT_I2C I2c,
	_In_reads_bytes_(OutLength) const VOID *Out, _In_ ULONG OutLength,
	_Out_writes_bytes_(InLength) VOID *In, _In_ ULONG InLength);

#endif
