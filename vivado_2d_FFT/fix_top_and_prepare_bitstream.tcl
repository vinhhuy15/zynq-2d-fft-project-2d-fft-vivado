set project_dir [file normalize [file dirname [info script]]]
set project_file [file join $project_dir project_1.xpr]
set bd_file [file join $project_dir project_1.srcs sources_1 bd design_1 design_1.bd]
set wrapper_file [file join $project_dir project_1.srcs sources_1 bd design_1 hdl design_1_wrapper.v]

open_project $project_file
open_bd_design $bd_file

validate_bd_design
save_bd_design
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

puts "sources_1 top is now: [get_property top [get_filesets sources_1]]"
puts "FFT2D top/wrapper preparation completed."

close_project
