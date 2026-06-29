# 2026-06-27T10:52:02.784113
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "fft_platform",hw_design = "$COMPONENT_LOCATION/../../vivado_2d_FFT/fft_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="fft_application",platform = "$COMPONENT_LOCATION/../fft_platform/export/fft_platform/fft_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="fft_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="fft_application")
comp.build()

status = platform.build()

comp.build()

vitis.dispose()

