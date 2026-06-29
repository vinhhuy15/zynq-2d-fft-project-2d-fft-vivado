// ==============================================================
// File generated on Thu Jun 25 21:35:17 +0700 2026
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
// SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
// IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xfft2d_fixed_top.h"

extern XFft2d_fixed_top_Config XFft2d_fixed_top_ConfigTable[];

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

