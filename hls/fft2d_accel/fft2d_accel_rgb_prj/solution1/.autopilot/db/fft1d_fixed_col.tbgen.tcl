set moduleName fft1d_fixed_col
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set isPipelined_legacy 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set restart_counter_num 0
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 18
set C_modelName {fft1d_fixed_col}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict data_real { MEM_WIDTH 32 MEM_SIZE 256 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
dict set ap_memory_interface_dict data_imag { MEM_WIDTH 32 MEM_SIZE 256 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
set C_modelArgList {
	{ data_real int 32 regular {array 64 { 2 1 } 1 1 }  }
	{ data_imag int 32 regular {array 64 { 2 1 } 1 1 }  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "data_real", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "data_imag", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} ]}
# RTL Port declarations: 
set portNum 38
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ data_real_address0 sc_out sc_lv 6 signal 0 } 
	{ data_real_ce0 sc_out sc_logic 1 signal 0 } 
	{ data_real_we0 sc_out sc_logic 1 signal 0 } 
	{ data_real_d0 sc_out sc_lv 32 signal 0 } 
	{ data_real_q0 sc_in sc_lv 32 signal 0 } 
	{ data_real_address1 sc_out sc_lv 6 signal 0 } 
	{ data_real_ce1 sc_out sc_logic 1 signal 0 } 
	{ data_real_q1 sc_in sc_lv 32 signal 0 } 
	{ data_imag_address0 sc_out sc_lv 6 signal 1 } 
	{ data_imag_ce0 sc_out sc_logic 1 signal 1 } 
	{ data_imag_we0 sc_out sc_logic 1 signal 1 } 
	{ data_imag_d0 sc_out sc_lv 32 signal 1 } 
	{ data_imag_q0 sc_in sc_lv 32 signal 1 } 
	{ data_imag_address1 sc_out sc_lv 6 signal 1 } 
	{ data_imag_ce1 sc_out sc_logic 1 signal 1 } 
	{ data_imag_q1 sc_in sc_lv 32 signal 1 } 
	{ grp_fu_480_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_480_p_din1 sc_out sc_lv 13 signal -1 } 
	{ grp_fu_480_p_dout0 sc_in sc_lv 45 signal -1 } 
	{ grp_fu_480_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_484_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_484_p_din1 sc_out sc_lv 13 signal -1 } 
	{ grp_fu_484_p_dout0 sc_in sc_lv 45 signal -1 } 
	{ grp_fu_484_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_488_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_488_p_din1 sc_out sc_lv 14 signal -1 } 
	{ grp_fu_488_p_dout0 sc_in sc_lv 44 signal -1 } 
	{ grp_fu_488_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_492_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_492_p_din1 sc_out sc_lv 14 signal -1 } 
	{ grp_fu_492_p_dout0 sc_in sc_lv 44 signal -1 } 
	{ grp_fu_492_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "data_real_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "data_real", "role": "address0" }} , 
 	{ "name": "data_real_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_real", "role": "ce0" }} , 
 	{ "name": "data_real_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_real", "role": "we0" }} , 
 	{ "name": "data_real_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_real", "role": "d0" }} , 
 	{ "name": "data_real_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_real", "role": "q0" }} , 
 	{ "name": "data_real_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "data_real", "role": "address1" }} , 
 	{ "name": "data_real_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_real", "role": "ce1" }} , 
 	{ "name": "data_real_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_real", "role": "q1" }} , 
 	{ "name": "data_imag_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "data_imag", "role": "address0" }} , 
 	{ "name": "data_imag_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_imag", "role": "ce0" }} , 
 	{ "name": "data_imag_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_imag", "role": "we0" }} , 
 	{ "name": "data_imag_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_imag", "role": "d0" }} , 
 	{ "name": "data_imag_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_imag", "role": "q0" }} , 
 	{ "name": "data_imag_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "data_imag", "role": "address1" }} , 
 	{ "name": "data_imag_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "data_imag", "role": "ce1" }} , 
 	{ "name": "data_imag_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "data_imag", "role": "q1" }} , 
 	{ "name": "grp_fu_480_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_480_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_480_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":13, "type": "signal", "bundle":{"name": "grp_fu_480_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_480_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":45, "type": "signal", "bundle":{"name": "grp_fu_480_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_480_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_480_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_484_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_484_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_484_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":13, "type": "signal", "bundle":{"name": "grp_fu_484_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_484_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":45, "type": "signal", "bundle":{"name": "grp_fu_484_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_484_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_484_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_488_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_488_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_488_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":14, "type": "signal", "bundle":{"name": "grp_fu_488_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_488_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":44, "type": "signal", "bundle":{"name": "grp_fu_488_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_488_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_488_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_492_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_492_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_492_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":14, "type": "signal", "bundle":{"name": "grp_fu_492_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_492_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":44, "type": "signal", "bundle":{"name": "grp_fu_492_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_492_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_492_p_ce", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	fft1d_fixed_col {
		data_real {Type IO LastRead 16 FirstWrite 4}
		data_imag {Type IO LastRead 16 FirstWrite 4}
		TWIDDLE_REAL {Type I LastRead -1 FirstWrite -1}
		TWIDDLE_IMAG {Type I LastRead -1 FirstWrite -1}}
	fft1d_fixed_col_Pipeline_VITIS_LOOP_135_2 {
		j {Type I LastRead 0 FirstWrite -1}
		j_2_out {Type O LastRead -1 FirstWrite 1}}
	fft1d_fixed_col_Pipeline_VITIS_LOOP_151_5 {
		select_ln151 {Type I LastRead 0 FirstWrite -1}
		len {Type I LastRead 0 FirstWrite -1}
		empty_42 {Type I LastRead 0 FirstWrite -1}
		data_real {Type IO LastRead 16 FirstWrite 21}
		data_imag {Type IO LastRead 16 FirstWrite 21}
		empty {Type I LastRead 0 FirstWrite -1}
		TWIDDLE_REAL {Type I LastRead -1 FirstWrite -1}
		TWIDDLE_IMAG {Type I LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "-1", "Max" : "-1"}
	, {"Name" : "Interval", "Min" : "-1", "Max" : "-1"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	data_real { ap_memory {  { data_real_address0 mem_address 1 6 }  { data_real_ce0 mem_ce 1 1 }  { data_real_we0 mem_we 1 1 }  { data_real_d0 mem_din 1 32 }  { data_real_q0 mem_dout 0 32 }  { data_real_address1 MemPortADDR2 1 6 }  { data_real_ce1 MemPortCE2 1 1 }  { data_real_q1 MemPortDOUT2 0 32 } } }
	data_imag { ap_memory {  { data_imag_address0 mem_address 1 6 }  { data_imag_ce0 mem_ce 1 1 }  { data_imag_we0 mem_we 1 1 }  { data_imag_d0 mem_din 1 32 }  { data_imag_q0 mem_dout 0 32 }  { data_imag_address1 MemPortADDR2 1 6 }  { data_imag_ce1 MemPortCE2 1 1 }  { data_imag_q1 MemPortDOUT2 0 32 } } }
}
