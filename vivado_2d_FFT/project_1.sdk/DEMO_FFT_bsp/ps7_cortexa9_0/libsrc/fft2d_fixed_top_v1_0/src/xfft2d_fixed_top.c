// ==============================================================
// File generated on Thu Jun 25 21:35:17 +0700 2026
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
// SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
// IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xfft2d_fixed_top.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFft2d_fixed_top_CfgInitialize(XFft2d_fixed_top *InstancePtr, XFft2d_fixed_top_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Ctrl_BaseAddress = ConfigPtr->Ctrl_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFft2d_fixed_top_Start(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL) & 0x80;
    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XFft2d_fixed_top_IsDone(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XFft2d_fixed_top_IsIdle(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XFft2d_fixed_top_IsReady(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XFft2d_fixed_top_EnableAutoRestart(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL, 0x80);
}

void XFft2d_fixed_top_DisableAutoRestart(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_AP_CTRL, 0);
}

void XFft2d_fixed_top_Set_input_V(XFft2d_fixed_top *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_INPUT_V_DATA, Data);
}

u32 XFft2d_fixed_top_Get_input_V(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_INPUT_V_DATA);
    return Data;
}

void XFft2d_fixed_top_Set_output_real_V(XFft2d_fixed_top *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_OUTPUT_REAL_V_DATA, Data);
}

u32 XFft2d_fixed_top_Get_output_real_V(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_OUTPUT_REAL_V_DATA);
    return Data;
}

void XFft2d_fixed_top_Set_output_imag_V(XFft2d_fixed_top *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_OUTPUT_IMAG_V_DATA, Data);
}

u32 XFft2d_fixed_top_Get_output_imag_V(XFft2d_fixed_top *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_OUTPUT_IMAG_V_DATA);
    return Data;
}

void XFft2d_fixed_top_InterruptGlobalEnable(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_GIE, 1);
}

void XFft2d_fixed_top_InterruptGlobalDisable(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_GIE, 0);
}

void XFft2d_fixed_top_InterruptEnable(XFft2d_fixed_top *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_IER);
    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_IER, Register | Mask);
}

void XFft2d_fixed_top_InterruptDisable(XFft2d_fixed_top *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_IER);
    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_IER, Register & (~Mask));
}

void XFft2d_fixed_top_InterruptClear(XFft2d_fixed_top *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft2d_fixed_top_WriteReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_ISR, Mask);
}

u32 XFft2d_fixed_top_InterruptGetEnabled(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_IER);
}

u32 XFft2d_fixed_top_InterruptGetStatus(XFft2d_fixed_top *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFft2d_fixed_top_ReadReg(InstancePtr->Ctrl_BaseAddress, XFFT2D_FIXED_TOP_CTRL_ADDR_ISR);
}

