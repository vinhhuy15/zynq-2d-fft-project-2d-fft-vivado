set project_dir [file normalize [file dirname [info script]]]
set project_file [file join $project_dir project_1.xpr]
set bd_file [file join $project_dir project_1.srcs sources_1 bd design_1 design_1.bd]
set xsa_file [file join $project_dir fft_wrapper.xsa]

open_project $project_file
open_bd_design $bd_file

validate_bd_design
save_bd_design
generate_target all [get_files $bd_file]
export_ip_user_files -of_objects [get_files $bd_file] -no_script -sync -force -quiet

set_property top design_1_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
puts "synth_1 status: $synth_status"
if {[string first "Complete" $synth_status] < 0} {
    error "Synthesis did not complete: $synth_status"
}

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "impl_1 status: $impl_status"
if {[string first "Complete" $impl_status] < 0} {
    error "Implementation/bitstream did not complete: $impl_status"
}

write_hw_platform -fixed -include_bit -force $xsa_file
puts "Exported hardware platform: $xsa_file"

close_project
