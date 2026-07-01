# 2026-06-29T10:19:31.440062500
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="fft_platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado_2d_FFT/fft_rgb.xsa")

status = platform.build()

comp = client.get_component(name="fft_application")
comp.build()

vitis.dispose()

