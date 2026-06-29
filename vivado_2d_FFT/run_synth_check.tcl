set project_dir [file normalize [file dirname [info script]]]
set project_file [file join $project_dir project_1.xpr]

open_project $project_file

set_property top design_1_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
puts "synth_1 status: $synth_status"

if {[string first "Complete" $synth_status] < 0} {
    error "Synthesis did not complete: $synth_status"
}

close_project
