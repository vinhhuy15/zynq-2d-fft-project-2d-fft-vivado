# Paper HLS Results Summary

Generated from Vitis HLS reports and C-simulation logs in this folder.

## Twiddle Resource Comparison

| Variant | BRAM_18K | DSP | FF | LUT |
|---|---:|---:|---:|---:|
| Runtime sin/cos | 78 | 197 | 18271 | 25593 |
| Twiddle LUT | 66 | 8 | 9869 | 12375 |
| Reduction (%) | 15.4 | 95.9 | 46.0 | 51.6 |

## Bit-Width Sweep

| Format | Pass | Worst Real MaxAbs | Worst Imag MaxAbs | BRAM_18K | DSP | FF | LUT | Status |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| ap_fixed<32,20> | 4/4 | 48.1013 | 34.5814 | 74 | 8 | 10387 | 12477 | PASS |
| ap_fixed<28,20> | 4/4 | 390.4006 | 308.7507 | 66 | 8 | 9869 | 12375 | PASS |
| ap_fixed<24,20> | 0/4 | 4928.0017 | 3312.7220 | - | - | - | - | FAIL |
| ap_fixed<22,20> | 0/4 | 44172.9983 | 30855.2780 | - | - | - | - | FAIL |
| ap_fixed<24,16> | 0/4 | 489472.0039 | 295416.7260 | - | - | - | - | FAIL |
| ap_fixed<24,12> | 0/4 | 520192.0002 | 326136.7223 | - | - | - | - | FAIL |
| ap_fixed<20,12> | 0/4 | 520192.0039 | 326136.7260 | - | - | - | - | FAIL |

## Paper Note

Use the Twiddle LUT row from the first table as the selected 28/20 resource row. This keeps Table V, Table VI, and Figure 6 synchronized to the same HLS report source.
