// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xfft2d_fixed_top.h"

extern XFft2d_fixed_top_Config XFft2d_fixed_top_ConfigTable[];

#ifdef SDT
XFft2d_fixed_top_Config *XFft2d_fixed_top_LookupConfig(UINTPTR BaseAddress) {
	XFft2d_fixed_top_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XFft2d_fixed_top_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XFft2d_fixed_top_ConfigTable[Index].Ctrl_BaseAddress == BaseAddress) {
			ConfigPtr = &XFft2d_fixed_top_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFft2d_fixed_top_Initialize(XFft2d_fixed_top *InstancePtr, UINTPTR BaseAddress) {
	XFft2d_fixed_top_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFft2d_fixed_top_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFft2d_fixed_top_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XFft2d_fixed_top_Config *XFft2d_fixed_top_LookupConfig(u16 DeviceId) {
	XFft2d_fixed_top_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFFT2D_FIXED_TOP_NUM_INSTANCES; Index++) {
		if (XFft2d_fixed_top_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFft2d_fixed_top_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFft2d_fixed_top_Initialize(XFft2d_fixed_top *InstancePtr, u16 DeviceId) {
	XFft2d_fixed_top_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFft2d_fixed_top_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFft2d_fixed_top_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

