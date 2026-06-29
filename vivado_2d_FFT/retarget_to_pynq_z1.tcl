set project_dir [file normalize [file dirname [info script]]]
set project_file [file join $project_dir project_1.xpr]
set bd_file [file join $project_dir project_1.srcs sources_1 bd design_1 design_1.bd]
set wrapper_file [file join $project_dir project_1.srcs sources_1 bd design_1 hdl design_1_wrapper.v]
set ps7_config_file [file join $project_dir pynq_z1_ps7_config.tcl]
set target_part "xc7z020clg400-1"

if {![file exists $ps7_config_file]} {
    error "Missing PYNQ-Z1 PS7 config file: $ps7_config_file"
}

source $ps7_config_file

open_project $project_file

puts "Retargeting project to PYNQ-Z1 compatible part: $target_part"
set_property part $target_part [current_project]
catch {set_property board_part "" [current_project]}
catch {set_property platform.board_id pynq-z1 [current_project]}

puts "Refreshing/upgrading IP after part change..."
update_ip_catalog
set all_ips [get_ips -quiet]
if {[llength $all_ips] > 0} {
    catch {report_ip_status -name ip_status_pynq_z1}
    catch {upgrade_ip $all_ips}
}

open_bd_design $bd_file
current_bd_design design_1

puts "Applying PYNQ-Z1 Zynq PS7 DDR/MIO/clock preset..."
set ps7 [get_bd_cells processing_system7_0]
set_property -dict $pynq_z1_ps7_config $ps7

# Keep the interfaces required by this FFT accelerator design.
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_M_AXI_GP1 {0} \
    CONFIG.PCW_USE_S_AXI_GP0 {0} \
    CONFIG.PCW_USE_S_AXI_GP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_USE_S_AXI_HP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP2 {0} \
    CONFIG.PCW_USE_S_AXI_HP3 {0} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {0} \
    CONFIG.PCW_EN_CLK2_PORT {0} \
    CONFIG.PCW_EN_CLK3_PORT {0} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
    CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
    CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
] $ps7

puts "Re-validating block design..."
assign_bd_address
validate_bd_design
save_bd_design

puts "Regenerating BD output products and wrapper..."
generate_target all [get_files $bd_file]
export_ip_user_files -of_objects [get_files $bd_file] -no_script -sync -force -quiet

if {![file exists $wrapper_file]} {
    make_wrapper -files [get_files $bd_file] -top
}
if {[llength [get_files -quiet $wrapper_file]] == 0} {
    add_files -norecurse $wrapper_file
}

set_property top design_1_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project part: [get_property part [current_project]]"
puts "BD validated: [get_property VALIDATED [current_bd_design]]"
puts "Top: [get_property top [get_filesets sources_1]]"

close_project
puts "PYNQ-Z1 retarget step completed."
