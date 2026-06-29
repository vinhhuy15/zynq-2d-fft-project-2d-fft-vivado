set project_dir [file normalize [file dirname [info script]]]
set project_file [file join $project_dir project_1.xpr]
set bd_file [file join $project_dir project_1.srcs sources_1 bd design_1 design_1.bd]
set fft_ip_repo [file normalize {D:/2D_FFT/zynq-2d-fft/hls/fft2d_accel/fft2d_accel_prj_2018/solution1/impl/ip}]

proc has_bd_cell {cell_name} {
    expr {[llength [get_bd_cells -quiet $cell_name]] != 0}
}

proc has_bd_pin {pin_name} {
    expr {[llength [get_bd_pins -quiet $pin_name]] != 0}
}

proc has_bd_intf_pin {pin_name} {
    expr {[llength [get_bd_intf_pins -quiet $pin_name]] != 0}
}

proc disconnect_pin_if_connected {pin_name} {
    set pin [get_bd_pins -quiet $pin_name]
    if {[llength $pin] == 0} {
        return
    }
    set nets [get_bd_nets -quiet -of_objects $pin]
    foreach net $nets {
        catch {disconnect_bd_net $net $pin}
    }
}

proc connect_pins_once {pin_a pin_b} {
    if {![has_bd_pin $pin_a] || ![has_bd_pin $pin_b]} {
        puts "WARN: Cannot connect missing pin(s): $pin_a $pin_b"
        return
    }
    set a [get_bd_pins $pin_a]
    set b [get_bd_pins $pin_b]
    set net_a [get_bd_nets -quiet -of_objects $a]
    set net_b [get_bd_nets -quiet -of_objects $b]

    if {[llength $net_a] && [llength $net_b] && [string equal [get_property NAME $net_a] [get_property NAME $net_b]]} {
        return
    }
    if {[llength $net_b]} {
        disconnect_pin_if_connected $pin_b
    }
    connect_bd_net $a $b
}

proc connect_intf_once {pin_a pin_b} {
    if {![has_bd_intf_pin $pin_a] || ![has_bd_intf_pin $pin_b]} {
        puts "WARN: Cannot connect missing interface pin(s): $pin_a $pin_b"
        return
    }
    set a [get_bd_intf_pins $pin_a]
    set b [get_bd_intf_pins $pin_b]
    set net_a [get_bd_intf_nets -quiet -of_objects $a]
    set net_b [get_bd_intf_nets -quiet -of_objects $b]

    if {[llength $net_a] && [llength $net_b] && [string equal [get_property NAME $net_a] [get_property NAME $net_b]]} {
        return
    }
    if {[llength $net_b]} {
        catch {disconnect_bd_intf_net $net_b $b}
    }
    if {[llength $net_a]} {
        connect_bd_intf_net $net_a $b
    } else {
        connect_bd_intf_net $a $b
    }
}

open_project $project_file

if {[file exists $fft_ip_repo]} {
    set_property ip_repo_paths [list $fft_ip_repo] [current_project]
    update_ip_catalog
} else {
    puts "WARN: FFT IP repository not found: $fft_ip_repo"
}

open_bd_design $bd_file
current_bd_design design_1

set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.0} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
] [get_bd_cells processing_system7_0]

set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_1]

# A single FFT interrupt can connect directly to IRQ_F2P. If an old xlconcat is
# still present with two inputs, remove it to avoid width/input warnings.
if {[has_bd_cell xlconcat_0]} {
    catch {disconnect_pin_if_connected xlconcat_0/In0}
    catch {disconnect_pin_if_connected xlconcat_0/In1}
    catch {disconnect_pin_if_connected xlconcat_0/dout}
    delete_bd_objs [get_bd_cells xlconcat_0]
}

connect_intf_once processing_system7_0/M_AXI_GP0 axi_interconnect_0/S00_AXI
connect_intf_once axi_interconnect_0/M00_AXI fft2d_fixed_top_0/s_axi_CTRL

connect_intf_once fft2d_fixed_top_0/m_axi_gmem0 axi_interconnect_1/S00_AXI
connect_intf_once fft2d_fixed_top_0/m_axi_gmem1 axi_interconnect_1/S01_AXI
connect_intf_once fft2d_fixed_top_0/m_axi_gmem2 axi_interconnect_1/S02_AXI
connect_intf_once axi_interconnect_1/M00_AXI processing_system7_0/S_AXI_HP0

connect_pins_once processing_system7_0/FCLK_CLK0 proc_sys_reset_0/slowest_sync_clk
connect_pins_once processing_system7_0/FCLK_RESET0_N proc_sys_reset_0/ext_reset_in

foreach clk_pin [list \
    fft2d_fixed_top_0/ap_clk \
    processing_system7_0/M_AXI_GP0_ACLK \
    processing_system7_0/S_AXI_HP0_ACLK \
    axi_interconnect_0/ACLK \
    axi_interconnect_0/S00_ACLK \
    axi_interconnect_0/M00_ACLK \
    axi_interconnect_1/ACLK \
    axi_interconnect_1/S00_ACLK \
    axi_interconnect_1/S01_ACLK \
    axi_interconnect_1/S02_ACLK \
    axi_interconnect_1/M00_ACLK \
    ila_0/clk \
] {
    connect_pins_once processing_system7_0/FCLK_CLK0 $clk_pin
}

foreach reset_pin [list \
    fft2d_fixed_top_0/ap_rst_n \
    axi_interconnect_0/ARESETN \
    axi_interconnect_0/S00_ARESETN \
    axi_interconnect_0/M00_ARESETN \
    axi_interconnect_1/ARESETN \
    axi_interconnect_1/S00_ARESETN \
    axi_interconnect_1/S01_ARESETN \
    axi_interconnect_1/S02_ARESETN \
    axi_interconnect_1/M00_ARESETN \
] {
    disconnect_pin_if_connected $reset_pin
    connect_pins_once proc_sys_reset_0/peripheral_aresetn $reset_pin
}

connect_pins_once fft2d_fixed_top_0/interrupt processing_system7_0/IRQ_F2P

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

close_project
puts "FFT2D block design fix completed."
