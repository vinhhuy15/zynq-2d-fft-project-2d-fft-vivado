# Package the synthesized HLS design as a Vivado/Vitis IP only.
# This avoids the optional sysgen packaging path, which can trigger Tcl app
# loading issues on some Vivado installations.

set workspace_root [file normalize "."]
set amd_tclstore "C:/AMDDesignTools/2025.2/Vivado/data/XilinxTclStore"
foreach pkg_dir [list \
    [file join $amd_tclstore support appinit] \
    [file join $amd_tclstore support args] \
    [file join $amd_tclstore tclapp xilinx modelsim] \
    [file join $amd_tclstore tclapp xilinx questa] \
    [file join $amd_tclstore tclapp xilinx xsim] \
    [file join $amd_tclstore tclapp aldec activehdl] \
    [file join $amd_tclstore tclapp aldec riviera] \
] {
    if {[file exists $pkg_dir] && [lsearch -exact $::auto_path $pkg_dir] < 0} {
        lappend ::auto_path $pkg_dir
    }
}
package require ::tclapp::support::appinit
source [file join $workspace_root hls fft2d_accel vivado_tclapp_load_fix.tcl]

source -notrace "C:/AMDDesignTools/2025.2/Vitis/common/scripts/ipxhls.tcl"

set ip_out_dir "D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/fft2d_accel_rgb_prj/solution1/impl/ip"
set data_file "D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/fft2d_accel_rgb_prj/solution1/solution1_data.json"
set src_dir [file dir $data_file]
set ip_types {vitis}
set ippack_opts_dict {}

puts "Packaging HLS IP with ip_types=$ip_types"
if {[catch {::ipx::utils::package_hls_ip $ip_out_dir $data_file $ip_types $src_dir $ippack_opts_dict} err]} {
    puts "Packaging failed:"
    puts $err
    puts $::errorInfo
    error $err
}
