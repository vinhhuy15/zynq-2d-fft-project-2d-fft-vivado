// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XFFT2D_FIXED_TOP_H
#define XFFT2D_FIXED_TOP_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xfft2d_fixed_top_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Ctrl_BaseAddress;
} XFft2d_fixed_top_Config;
#endif

typedef struct {
    u64 Ctrl_BaseAddress;
    u32 IsReady;
} XFft2d_fixed_top;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFft2d_fixed_top_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFft2d_fixed_top_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFft2d_fixed_top_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFft2d_fixed_top_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XFft2d_fixed_top_Initialize(XFft2d_fixed_top *InstancePtr, UINTPTR BaseAddress);
XFft2d_fixed_top_Config* XFft2d_fixed_top_LookupConfig(UINTPTR BaseAddress);
#else
int XFft2d_fixed_top_Initialize(XFft2d_fixed_top *InstancePtr, u16 DeviceId);
XFft2d_fixed_top_Config* XFft2d_fixed_top_LookupConfig(u16 DeviceId);
#endif
int XFft2d_fixed_top_CfgInitialize(XFft2d_fixed_top *InstancePtr, XFft2d_fixed_top_Config *ConfigPtr);
#else
int XFft2d_fixed_top_Initialize(XFft2d_fixed_top *InstancePtr, const char* InstanceName);
int XFft2d_fixed_top_Release(XFft2d_fixed_top *InstancePtr);
#endif

void XFft2d_fixed_top_Start(XFft2d_fixed_top *InstancePtr);
u32 XFft2d_fixed_top_IsDone(XFft2d_fixed_top *InstancePtr);
u32 XFft2d_fixed_top_IsIdle(XFft2d_fixed_top *InstancePtr);
u32 XFft2d_fixed_top_IsReady(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_EnableAutoRestart(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_DisableAutoRestart(XFft2d_fixed_top *InstancePtr);

void XFft2d_fixed_top_Set_input_r(XFft2d_fixed_top *InstancePtr, u64 Data);
u64 XFft2d_fixed_top_Get_input_r(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_Set_output_real(XFft2d_fixed_top *InstancePtr, u64 Data);
u64 XFft2d_fixed_top_Get_output_real(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_Set_output_imag(XFft2d_fixed_top *InstancePtr, u64 Data);
u64 XFft2d_fixed_top_Get_output_imag(XFft2d_fixed_top *InstancePtr);

void XFft2d_fixed_top_InterruptGlobalEnable(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_InterruptGlobalDisable(XFft2d_fixed_top *InstancePtr);
void XFft2d_fixed_top_InterruptEnable(XFft2d_fixed_top *InstancePtr, u32 Mask);
void XFft2d_fixed_top_InterruptDisable(XFft2d_fixed_top *InstancePtr, u32 Mask);
void XFft2d_fixed_top_InterruptClear(XFft2d_fixed_top *InstancePtr, u32 Mask);
u32 XFft2d_fixed_top_InterruptGetEnabled(XFft2d_fixed_top *InstancePtr);
u32 XFft2d_fixed_top_InterruptGetStatus(XFft2d_fixed_top *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
