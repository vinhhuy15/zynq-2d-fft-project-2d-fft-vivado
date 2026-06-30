# Vivado 2025.2 can fail HLS IP packaging if the per-user XilinxTclStore
# support/appinit package is not on auto_path. Add it explicitly, then run
# the HLS-generated IP packager script.

set workspace_root [file normalize "."]
set user_tcl_store [file normalize "C:/Users/huyvi/AppData/Roaming/Xilinx/Vivado/2025.2/XilinxTclStore"]
set appinit_file [file join $workspace_root hls fft2d_accel tclstore_support appinit.tcl]
if {[file exists $appinit_file]} {
    source $appinit_file
    puts "Preloaded TclStore appinit package from workspace copy: $appinit_file"
}
set xsim_dir [file join $workspace_root hls fft2d_accel tclstore_support xsim]
set xsim_file [file join $xsim_dir xsim.tcl]
if {[file exists $xsim_file]} {
    if {[lsearch -exact $::auto_path $xsim_dir] < 0} {
        lappend ::auto_path $xsim_dir
    }
    source $xsim_file
    puts "Preloaded TclStore xsim package from workspace copy: $xsim_file"
}

foreach support_dir [list \
    [file join $user_tcl_store support] \
    [file join $user_tcl_store support appinit] \
    [file join $user_tcl_store support args] \
] {
    if {[file isdirectory $support_dir] && [lsearch -exact $::auto_path $support_dir] < 0} {
        lappend ::auto_path $support_dir
    }
}

puts "Vivado auto_path includes TclStore support/appinit: [expr {[lsearch -exact $::auto_path [file join $user_tcl_store support appinit]] >= 0}]"
puts "TclStore appinit package version: [package provide ::tclapp::support::appinit]"
puts "TclStore xsim package version: [package provide ::tclapp::xilinx::xsim]"

source [file normalize "hls/fft2d_accel/fft2d_accel_rgb_prj/solution1/impl/ip/run_ippack.tcl"]
