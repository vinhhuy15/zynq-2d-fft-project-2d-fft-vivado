// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Mon Jun 29 10:00:37 2026
// Host        : VINHHUY15 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/zynq-2d-fft-project-2d-fft-vivado/vivado_2d_FFT/project_1.gen/sources_1/bd/design_1/ip/design_1_fft2d_fixed_top_0_0/design_1_fft2d_fixed_top_0_0_stub.v
// Design      : design_1_fft2d_fixed_top_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "design_1_fft2d_fixed_top_0_0,fft2d_fixed_top,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "HLS" *) 
(* X_CORE_INFO = "fft2d_fixed_top,Vivado 2025.2" *) (* hls_module = "yes" *) 
module design_1_fft2d_fixed_top_0_0(s_axi_CTRL_AWADDR, s_axi_CTRL_AWVALID, 
  s_axi_CTRL_AWREADY, s_axi_CTRL_WDATA, s_axi_CTRL_WSTRB, s_axi_CTRL_WVALID, 
  s_axi_CTRL_WREADY, s_axi_CTRL_BRESP, s_axi_CTRL_BVALID, s_axi_CTRL_BREADY, 
  s_axi_CTRL_ARADDR, s_axi_CTRL_ARVALID, s_axi_CTRL_ARREADY, s_axi_CTRL_RDATA, 
  s_axi_CTRL_RRESP, s_axi_CTRL_RVALID, s_axi_CTRL_RREADY, ap_clk, ap_rst_n, interrupt, 
  m_axi_gmem0_AWADDR, m_axi_gmem0_AWLEN, m_axi_gmem0_AWSIZE, m_axi_gmem0_AWBURST, 
  m_axi_gmem0_AWLOCK, m_axi_gmem0_AWREGION, m_axi_gmem0_AWCACHE, m_axi_gmem0_AWPROT, 
  m_axi_gmem0_AWQOS, m_axi_gmem0_AWVALID, m_axi_gmem0_AWREADY, m_axi_gmem0_WDATA, 
  m_axi_gmem0_WSTRB, m_axi_gmem0_WLAST, m_axi_gmem0_WVALID, m_axi_gmem0_WREADY, 
  m_axi_gmem0_BRESP, m_axi_gmem0_BVALID, m_axi_gmem0_BREADY, m_axi_gmem0_ARADDR, 
  m_axi_gmem0_ARLEN, m_axi_gmem0_ARSIZE, m_axi_gmem0_ARBURST, m_axi_gmem0_ARLOCK, 
  m_axi_gmem0_ARREGION, m_axi_gmem0_ARCACHE, m_axi_gmem0_ARPROT, m_axi_gmem0_ARQOS, 
  m_axi_gmem0_ARVALID, m_axi_gmem0_ARREADY, m_axi_gmem0_RDATA, m_axi_gmem0_RRESP, 
  m_axi_gmem0_RLAST, m_axi_gmem0_RVALID, m_axi_gmem0_RREADY, m_axi_gmem1_AWADDR, 
  m_axi_gmem1_AWLEN, m_axi_gmem1_AWSIZE, m_axi_gmem1_AWBURST, m_axi_gmem1_AWLOCK, 
  m_axi_gmem1_AWREGION, m_axi_gmem1_AWCACHE, m_axi_gmem1_AWPROT, m_axi_gmem1_AWQOS, 
  m_axi_gmem1_AWVALID, m_axi_gmem1_AWREADY, m_axi_gmem1_WDATA, m_axi_gmem1_WSTRB, 
  m_axi_gmem1_WLAST, m_axi_gmem1_WVALID, m_axi_gmem1_WREADY, m_axi_gmem1_BRESP, 
  m_axi_gmem1_BVALID, m_axi_gmem1_BREADY, m_axi_gmem1_ARADDR, m_axi_gmem1_ARLEN, 
  m_axi_gmem1_ARSIZE, m_axi_gmem1_ARBURST, m_axi_gmem1_ARLOCK, m_axi_gmem1_ARREGION, 
  m_axi_gmem1_ARCACHE, m_axi_gmem1_ARPROT, m_axi_gmem1_ARQOS, m_axi_gmem1_ARVALID, 
  m_axi_gmem1_ARREADY, m_axi_gmem1_RDATA, m_axi_gmem1_RRESP, m_axi_gmem1_RLAST, 
  m_axi_gmem1_RVALID, m_axi_gmem1_RREADY, m_axi_gmem2_AWADDR, m_axi_gmem2_AWLEN, 
  m_axi_gmem2_AWSIZE, m_axi_gmem2_AWBURST, m_axi_gmem2_AWLOCK, m_axi_gmem2_AWREGION, 
  m_axi_gmem2_AWCACHE, m_axi_gmem2_AWPROT, m_axi_gmem2_AWQOS, m_axi_gmem2_AWVALID, 
  m_axi_gmem2_AWREADY, m_axi_gmem2_WDATA, m_axi_gmem2_WSTRB, m_axi_gmem2_WLAST, 
  m_axi_gmem2_WVALID, m_axi_gmem2_WREADY, m_axi_gmem2_BRESP, m_axi_gmem2_BVALID, 
  m_axi_gmem2_BREADY, m_axi_gmem2_ARADDR, m_axi_gmem2_ARLEN, m_axi_gmem2_ARSIZE, 
  m_axi_gmem2_ARBURST, m_axi_gmem2_ARLOCK, m_axi_gmem2_ARREGION, m_axi_gmem2_ARCACHE, 
  m_axi_gmem2_ARPROT, m_axi_gmem2_ARQOS, m_axi_gmem2_ARVALID, m_axi_gmem2_ARREADY, 
  m_axi_gmem2_RDATA, m_axi_gmem2_RRESP, m_axi_gmem2_RLAST, m_axi_gmem2_RVALID, 
  m_axi_gmem2_RREADY)
/* synthesis syn_black_box black_box_pad_pin="s_axi_CTRL_AWADDR[5:0],s_axi_CTRL_AWVALID,s_axi_CTRL_AWREADY,s_axi_CTRL_WDATA[31:0],s_axi_CTRL_WSTRB[3:0],s_axi_CTRL_WVALID,s_axi_CTRL_WREADY,s_axi_CTRL_BRESP[1:0],s_axi_CTRL_BVALID,s_axi_CTRL_BREADY,s_axi_CTRL_ARADDR[5:0],s_axi_CTRL_ARVALID,s_axi_CTRL_ARREADY,s_axi_CTRL_RDATA[31:0],s_axi_CTRL_RRESP[1:0],s_axi_CTRL_RVALID,s_axi_CTRL_RREADY,ap_rst_n,interrupt,m_axi_gmem0_AWADDR[31:0],m_axi_gmem0_AWLEN[7:0],m_axi_gmem0_AWSIZE[2:0],m_axi_gmem0_AWBURST[1:0],m_axi_gmem0_AWLOCK[1:0],m_axi_gmem0_AWREGION[3:0],m_axi_gmem0_AWCACHE[3:0],m_axi_gmem0_AWPROT[2:0],m_axi_gmem0_AWQOS[3:0],m_axi_gmem0_AWVALID,m_axi_gmem0_AWREADY,m_axi_gmem0_WDATA[31:0],m_axi_gmem0_WSTRB[3:0],m_axi_gmem0_WLAST,m_axi_gmem0_WVALID,m_axi_gmem0_WREADY,m_axi_gmem0_BRESP[1:0],m_axi_gmem0_BVALID,m_axi_gmem0_BREADY,m_axi_gmem0_ARADDR[31:0],m_axi_gmem0_ARLEN[7:0],m_axi_gmem0_ARSIZE[2:0],m_axi_gmem0_ARBURST[1:0],m_axi_gmem0_ARLOCK[1:0],m_axi_gmem0_ARREGION[3:0],m_axi_gmem0_ARCACHE[3:0],m_axi_gmem0_ARPROT[2:0],m_axi_gmem0_ARQOS[3:0],m_axi_gmem0_ARVALID,m_axi_gmem0_ARREADY,m_axi_gmem0_RDATA[31:0],m_axi_gmem0_RRESP[1:0],m_axi_gmem0_RLAST,m_axi_gmem0_RVALID,m_axi_gmem0_RREADY,m_axi_gmem1_AWADDR[31:0],m_axi_gmem1_AWLEN[7:0],m_axi_gmem1_AWSIZE[2:0],m_axi_gmem1_AWBURST[1:0],m_axi_gmem1_AWLOCK[1:0],m_axi_gmem1_AWREGION[3:0],m_axi_gmem1_AWCACHE[3:0],m_axi_gmem1_AWPROT[2:0],m_axi_gmem1_AWQOS[3:0],m_axi_gmem1_AWVALID,m_axi_gmem1_AWREADY,m_axi_gmem1_WDATA[31:0],m_axi_gmem1_WSTRB[3:0],m_axi_gmem1_WLAST,m_axi_gmem1_WVALID,m_axi_gmem1_WREADY,m_axi_gmem1_BRESP[1:0],m_axi_gmem1_BVALID,m_axi_gmem1_BREADY,m_axi_gmem1_ARADDR[31:0],m_axi_gmem1_ARLEN[7:0],m_axi_gmem1_ARSIZE[2:0],m_axi_gmem1_ARBURST[1:0],m_axi_gmem1_ARLOCK[1:0],m_axi_gmem1_ARREGION[3:0],m_axi_gmem1_ARCACHE[3:0],m_axi_gmem1_ARPROT[2:0],m_axi_gmem1_ARQOS[3:0],m_axi_gmem1_ARVALID,m_axi_gmem1_ARREADY,m_axi_gmem1_RDATA[31:0],m_axi_gmem1_RRESP[1:0],m_axi_gmem1_RLAST,m_axi_gmem1_RVALID,m_axi_gmem1_RREADY,m_axi_gmem2_AWADDR[31:0],m_axi_gmem2_AWLEN[7:0],m_axi_gmem2_AWSIZE[2:0],m_axi_gmem2_AWBURST[1:0],m_axi_gmem2_AWLOCK[1:0],m_axi_gmem2_AWREGION[3:0],m_axi_gmem2_AWCACHE[3:0],m_axi_gmem2_AWPROT[2:0],m_axi_gmem2_AWQOS[3:0],m_axi_gmem2_AWVALID,m_axi_gmem2_AWREADY,m_axi_gmem2_WDATA[31:0],m_axi_gmem2_WSTRB[3:0],m_axi_gmem2_WLAST,m_axi_gmem2_WVALID,m_axi_gmem2_WREADY,m_axi_gmem2_BRESP[1:0],m_axi_gmem2_BVALID,m_axi_gmem2_BREADY,m_axi_gmem2_ARADDR[31:0],m_axi_gmem2_ARLEN[7:0],m_axi_gmem2_ARSIZE[2:0],m_axi_gmem2_ARBURST[1:0],m_axi_gmem2_ARLOCK[1:0],m_axi_gmem2_ARREGION[3:0],m_axi_gmem2_ARCACHE[3:0],m_axi_gmem2_ARPROT[2:0],m_axi_gmem2_ARQOS[3:0],m_axi_gmem2_ARVALID,m_axi_gmem2_ARREADY,m_axi_gmem2_RDATA[31:0],m_axi_gmem2_RRESP[1:0],m_axi_gmem2_RLAST,m_axi_gmem2_RVALID,m_axi_gmem2_RREADY" */
/* synthesis syn_force_seq_prim="ap_clk" */;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL AWADDR" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_CTRL, ADDR_WIDTH 6, DATA_WIDTH 32, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [5:0]s_axi_CTRL_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL AWVALID" *) input s_axi_CTRL_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL AWREADY" *) output s_axi_CTRL_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL WDATA" *) input [31:0]s_axi_CTRL_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL WSTRB" *) input [3:0]s_axi_CTRL_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL WVALID" *) input s_axi_CTRL_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL WREADY" *) output s_axi_CTRL_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL BRESP" *) output [1:0]s_axi_CTRL_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL BVALID" *) output s_axi_CTRL_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL BREADY" *) input s_axi_CTRL_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL ARADDR" *) input [5:0]s_axi_CTRL_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL ARVALID" *) input s_axi_CTRL_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL ARREADY" *) output s_axi_CTRL_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL RDATA" *) output [31:0]s_axi_CTRL_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL RRESP" *) output [1:0]s_axi_CTRL_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL RVALID" *) output s_axi_CTRL_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_CTRL RREADY" *) input s_axi_CTRL_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ap_clk CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_clk, ASSOCIATED_BUSIF s_axi_CTRL:m_axi_gmem0:m_axi_gmem1:m_axi_gmem2, ASSOCIATED_RESET ap_rst_n, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input ap_clk /* synthesis syn_isclock = 1 */;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ap_rst_n RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_rst_n, POLARITY ACTIVE_LOW, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {RST {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, INSERT_VIP 0" *) input ap_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME interrupt, SENSITIVITY LEVEL_HIGH, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {INTERRUPT {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, PortWidth 1" *) output interrupt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axi_gmem0, ADDR_WIDTH 32, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, MAX_READ_BURST_LENGTH 16, MAX_WRITE_BURST_LENGTH 16, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]m_axi_gmem0_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWLEN" *) output [7:0]m_axi_gmem0_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWSIZE" *) output [2:0]m_axi_gmem0_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWBURST" *) output [1:0]m_axi_gmem0_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWLOCK" *) output [1:0]m_axi_gmem0_AWLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWREGION" *) output [3:0]m_axi_gmem0_AWREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWCACHE" *) output [3:0]m_axi_gmem0_AWCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWPROT" *) output [2:0]m_axi_gmem0_AWPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWQOS" *) output [3:0]m_axi_gmem0_AWQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWVALID" *) output m_axi_gmem0_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 AWREADY" *) input m_axi_gmem0_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 WDATA" *) output [31:0]m_axi_gmem0_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 WSTRB" *) output [3:0]m_axi_gmem0_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 WLAST" *) output m_axi_gmem0_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 WVALID" *) output m_axi_gmem0_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 WREADY" *) input m_axi_gmem0_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 BRESP" *) input [1:0]m_axi_gmem0_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 BVALID" *) input m_axi_gmem0_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 BREADY" *) output m_axi_gmem0_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARADDR" *) output [31:0]m_axi_gmem0_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARLEN" *) output [7:0]m_axi_gmem0_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARSIZE" *) output [2:0]m_axi_gmem0_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARBURST" *) output [1:0]m_axi_gmem0_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARLOCK" *) output [1:0]m_axi_gmem0_ARLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARREGION" *) output [3:0]m_axi_gmem0_ARREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARCACHE" *) output [3:0]m_axi_gmem0_ARCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARPROT" *) output [2:0]m_axi_gmem0_ARPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARQOS" *) output [3:0]m_axi_gmem0_ARQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARVALID" *) output m_axi_gmem0_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 ARREADY" *) input m_axi_gmem0_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 RDATA" *) input [31:0]m_axi_gmem0_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 RRESP" *) input [1:0]m_axi_gmem0_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 RLAST" *) input m_axi_gmem0_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 RVALID" *) input m_axi_gmem0_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem0 RREADY" *) output m_axi_gmem0_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axi_gmem1, ADDR_WIDTH 32, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, MAX_READ_BURST_LENGTH 16, MAX_WRITE_BURST_LENGTH 16, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]m_axi_gmem1_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWLEN" *) output [7:0]m_axi_gmem1_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWSIZE" *) output [2:0]m_axi_gmem1_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWBURST" *) output [1:0]m_axi_gmem1_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWLOCK" *) output [1:0]m_axi_gmem1_AWLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWREGION" *) output [3:0]m_axi_gmem1_AWREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWCACHE" *) output [3:0]m_axi_gmem1_AWCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWPROT" *) output [2:0]m_axi_gmem1_AWPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWQOS" *) output [3:0]m_axi_gmem1_AWQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWVALID" *) output m_axi_gmem1_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 AWREADY" *) input m_axi_gmem1_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 WDATA" *) output [31:0]m_axi_gmem1_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 WSTRB" *) output [3:0]m_axi_gmem1_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 WLAST" *) output m_axi_gmem1_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 WVALID" *) output m_axi_gmem1_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 WREADY" *) input m_axi_gmem1_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 BRESP" *) input [1:0]m_axi_gmem1_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 BVALID" *) input m_axi_gmem1_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 BREADY" *) output m_axi_gmem1_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARADDR" *) output [31:0]m_axi_gmem1_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARLEN" *) output [7:0]m_axi_gmem1_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARSIZE" *) output [2:0]m_axi_gmem1_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARBURST" *) output [1:0]m_axi_gmem1_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARLOCK" *) output [1:0]m_axi_gmem1_ARLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARREGION" *) output [3:0]m_axi_gmem1_ARREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARCACHE" *) output [3:0]m_axi_gmem1_ARCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARPROT" *) output [2:0]m_axi_gmem1_ARPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARQOS" *) output [3:0]m_axi_gmem1_ARQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARVALID" *) output m_axi_gmem1_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 ARREADY" *) input m_axi_gmem1_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 RDATA" *) input [31:0]m_axi_gmem1_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 RRESP" *) input [1:0]m_axi_gmem1_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 RLAST" *) input m_axi_gmem1_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 RVALID" *) input m_axi_gmem1_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem1 RREADY" *) output m_axi_gmem1_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axi_gmem2, ADDR_WIDTH 32, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, MAX_READ_BURST_LENGTH 16, MAX_WRITE_BURST_LENGTH 16, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]m_axi_gmem2_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWLEN" *) output [7:0]m_axi_gmem2_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWSIZE" *) output [2:0]m_axi_gmem2_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWBURST" *) output [1:0]m_axi_gmem2_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWLOCK" *) output [1:0]m_axi_gmem2_AWLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWREGION" *) output [3:0]m_axi_gmem2_AWREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWCACHE" *) output [3:0]m_axi_gmem2_AWCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWPROT" *) output [2:0]m_axi_gmem2_AWPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWQOS" *) output [3:0]m_axi_gmem2_AWQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWVALID" *) output m_axi_gmem2_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 AWREADY" *) input m_axi_gmem2_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 WDATA" *) output [31:0]m_axi_gmem2_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 WSTRB" *) output [3:0]m_axi_gmem2_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 WLAST" *) output m_axi_gmem2_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 WVALID" *) output m_axi_gmem2_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 WREADY" *) input m_axi_gmem2_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 BRESP" *) input [1:0]m_axi_gmem2_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 BVALID" *) input m_axi_gmem2_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 BREADY" *) output m_axi_gmem2_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARADDR" *) output [31:0]m_axi_gmem2_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARLEN" *) output [7:0]m_axi_gmem2_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARSIZE" *) output [2:0]m_axi_gmem2_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARBURST" *) output [1:0]m_axi_gmem2_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARLOCK" *) output [1:0]m_axi_gmem2_ARLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARREGION" *) output [3:0]m_axi_gmem2_ARREGION;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARCACHE" *) output [3:0]m_axi_gmem2_ARCACHE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARPROT" *) output [2:0]m_axi_gmem2_ARPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARQOS" *) output [3:0]m_axi_gmem2_ARQOS;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARVALID" *) output m_axi_gmem2_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 ARREADY" *) input m_axi_gmem2_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 RDATA" *) input [31:0]m_axi_gmem2_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 RRESP" *) input [1:0]m_axi_gmem2_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 RLAST" *) input m_axi_gmem2_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 RVALID" *) input m_axi_gmem2_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_gmem2 RREADY" *) output m_axi_gmem2_RREADY;
endmodule
