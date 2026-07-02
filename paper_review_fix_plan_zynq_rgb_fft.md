# Checklist sửa paper IEEE: Zynq RGB 2D FFT Accelerator

**File gốc:** `zynq_rgb_fft_ieee_draft_verify.pdf`  
**Mục tiêu:** sửa paper để nhìn giống paper IEEE hơn, tối đa **10 trang**, ưu tiên tính chuyên nghiệp, tính nhất quán số liệu, chất lượng hình, văn phong học thuật và khả năng bảo vệ trước câu hỏi của giảng viên.

---

## 0. Đánh giá tổng quan hiện tại

Paper hiện có nền kỹ thuật khá tốt: có bài toán rõ, có thiết kế HLS, có Zynq/PS/PL, có fixed-point, có twiddle LUT, có số liệu resource/timing/power/latency và có kiểm chứng với NumPy. Tuy nhiên bản hiện tại vẫn tạo cảm giác giống **báo cáo project/lab report** hơn là paper IEEE hoàn chỉnh.

Các vấn đề lớn nhất:

1. Còn lỗi draft rất nghiêm trọng: `[?]`, `Hình ??`, `Bảng ??`, `(??)`.
2. Chưa có mục **References**.
3. Hình kiến trúc chính còn đơn giản, chưa thể hiện rõ AXI interconnect, DDR controller, AXI master, AXI4-Lite, HLS IP ports.
4. Có quá nhiều screenshot từ Vivado/Vitis HLS; chữ nhỏ, chiếm diện tích, nhìn chưa giống paper.
5. Thiếu so sánh với software baseline nên chữ “accelerator” chưa đủ thuyết phục.
6. Bảng fixed-point PASS/FAIL chưa nêu rõ tiêu chí PASS.
7. Số liệu HLS IP-level và Vivado system-level chưa được tách bạch đủ rõ.
8. Related Work hiện giống phần lý thuyết hơn là so sánh công trình liên quan.
9. Một số thuật ngữ và văn phong còn hơi giống báo cáo dự án, chưa đủ học thuật.

---

## 1. Ưu tiên sửa theo thứ tự

### Priority 1 — Bắt buộc sửa trước khi gửi

- [ ] Fix toàn bộ citation dạng `[?]`.
- [ ] Fix toàn bộ cross-reference dạng `Hình ??`, `Bảng ??`, `(??)`.
- [ ] Thêm mục `References` cuối paper.
- [ ] Kiểm tra tất cả hình/bảng đều được gọi trong text trước hoặc ngay sau vị trí xuất hiện.
- [ ] Kiểm tra caption figure/table không bị lỗi do IEEE auto-uppercase.
- [ ] Kiểm tra không còn lỗi render như `AP_FIXED` bị hiển thị thành `A P_F I X E D`.

### Priority 2 — Làm paper chuyên nghiệp hơn

- [ ] Vẽ lại Fig. 1 kiến trúc tổng quan.
- [ ] Thay screenshot Vivado/Vitis HLS bằng bảng sạch nếu có thể.
- [ ] Tách rõ số liệu **HLS IP-level** và **Vivado system-level**.
- [ ] Thêm tiêu chí PASS/FAIL cho fixed-point.
- [ ] Thêm bảng related work/comparison.
- [ ] Thêm software baseline hoặc ít nhất nói rõ chưa đo software runtime.

### Priority 3 — Tăng độ thuyết phục

- [ ] Thêm bảng speedup/software baseline nếu có số đo.
- [ ] Thêm pseudocode/algorithm cho luồng RGB 2D FFT.
- [ ] Thêm một đoạn giải thích vì sao chọn 64×64.
- [ ] Thêm một đoạn giải thích vì sao chọn memory-mapped thay vì AXI Stream/DMA trong baseline.
- [ ] Thêm một đoạn nói rõ kiểm chứng real/imag đáng tin hơn log-magnitude.

---

## 2. Lỗi cross-reference và citation cần sửa

Hiện trong paper còn nhiều chỗ dạng:

```text
[?]
Hình ??
Bảng ??
(??)
```

Các lỗi này làm paper nhìn như bản nháp chưa compile xong. Cần sửa tuyệt đối trước khi nộp.

### Việc cần làm trong LaTeX

1. Mỗi hình phải có:
```latex
\begin{figure}[t]
    \centering
    ...
    \caption{...}
    \label{fig:system_architecture}
\end{figure}
```

2. Gọi hình bằng:
```latex
Fig.~\ref{fig:system_architecture}
```

Nếu paper tiếng Việt, có thể dùng:
```latex
Hình~\ref{fig:system_architecture}
```

Nhưng nên thống nhất một kiểu. Với IEEE, khuyến nghị dùng `Fig.` và `Table`.

3. Mỗi bảng phải có:
```latex
\begin{table}[t]
    \caption{...}
    \label{tab:resource_utilization}
    \centering
    ...
\end{table}
```

4. Gọi bảng bằng:
```latex
Table~\ref{tab:resource_utilization}
```

5. Công thức DFT phải có label:
```latex
\begin{equation}
F(u,v)=...
\label{eq:2d_dft}
\end{equation}
```

Gọi lại bằng:
```latex
Eq.~\eqref{eq:2d_dft}
```

---

## 3. References cần bổ sung

Paper hiện chưa có mục References. Đây là lỗi lớn. Cần thêm ít nhất 8–12 tài liệu tham khảo.

### Nhóm tài liệu nên cite

1. FFT/DFT nền tảng:
   - Cooley–Tukey FFT paper.
   - Sách/tài liệu xử lý ảnh số hoặc DSP.

2. FPGA/HLS:
   - AMD/Xilinx Vitis HLS User Guide.
   - AMD/Xilinx Vivado Design Suite User Guide.
   - AMD/Xilinx FFT LogiCORE IP documentation.

3. Zynq/PYNQ:
   - Zynq-7000 Technical Reference Manual.
   - PYNQ paper/documentation nếu có dùng PYNQ-Z1.

4. Related work:
   - Paper về FPGA FFT.
   - Paper về HLS FFT.
   - Paper về FPGA image processing hoặc Zynq accelerator.

### Gợi ý BibTeX placeholder

Agent cần thay bằng BibTeX thật nếu có file `.bib`.

```bibtex
@article{cooley1965algorithm,
  title={An algorithm for the machine calculation of complex Fourier series},
  author={Cooley, James W. and Tukey, John W.},
  journal={Mathematics of Computation},
  volume={19},
  number={90},
  pages={297--301},
  year={1965}
}

@manual{xilinx_vitis_hls,
  title={Vitis High-Level Synthesis User Guide},
  organization={AMD Xilinx},
  year={2025}
}

@manual{xilinx_zynq_trm,
  title={Zynq-7000 SoC Technical Reference Manual},
  organization={AMD Xilinx}
}

@manual{xilinx_fft_ip,
  title={Fast Fourier Transform LogiCORE IP Product Guide},
  organization={AMD Xilinx}
}
```

### Lưu ý quan trọng

Không để citation kiểu `[?]`. Nếu chưa có BibTeX chính xác thì tạm thời comment đoạn citation đó hoặc thay bằng citation đã có. Paper nộp không được còn `[?]`.

---

## 4. Sửa cấu trúc paper

Cấu trúc hiện tại nhìn chung ổn:

```text
I. Introduction
II. Background and Related Work
III. Proposed System Architecture
IV. Hardware/Software Implementation
V. Experimental Setup
VI. Results and Evaluation
VII. Discussion
VIII. Conclusion and Future Work
```

Tuy nhiên cần chỉnh để mục II có phần related work thật sự.

### Đề xuất cấu trúc tối ưu

```text
I. Introduction
II. Background and Related Work
    A. Two-Dimensional FFT for Image Processing
    B. FPGA and HLS-Based FFT Acceleration
    C. Fixed-Point Design Considerations
    D. Position of This Work
III. Proposed System Architecture
    A. Zynq PS/PL System Overview
    B. RGB Processing Flow
    C. Row-Column 2D FFT Datapath
IV. Hardware/Software Implementation
    A. HLS Top Function and Interfaces
    B. Fixed-Point Configuration
    C. Twiddle LUT Optimization
    D. Verification Flow
V. Experimental Setup
VI. Results and Evaluation
    A. Resource Utilization
    B. Twiddle LUT Optimization
    C. Fixed-Point Bit-Width Evaluation
    D. Accuracy and Latency
    E. Timing and Power
    F. Visual Verification
VII. Discussion
VIII. Conclusion and Future Work
References
```

---

## 5. Thêm bảng Related Work

Hiện mục Related Work chưa đủ giống paper. Cần thêm một bảng so sánh ngắn để đặt bài của mình vào bối cảnh.

### Bảng đề xuất

```latex
\begin{table}[t]
\caption{Comparison with Related FPGA FFT Implementations}
\label{tab:related_work}
\centering
\begin{tabular}{lcccc}
\hline
Work & Platform & Transform & Data type & Main focus \\
\hline
{[}1{]} & FPGA & 1D/2D FFT & Fixed/Float & Throughput \\
{[}2{]} & Zynq & FFT accelerator & Fixed-point & HLS design \\
{[}3{]} & FPGA & Image FFT & Fixed-point & Resource usage \\
This work & Zynq-7000 & RGB 64$\times$64 2D FFT & ap\_fixed<28,20> & Resource-efficient baseline \\
\hline
\end{tabular}
\end{table}
```

### Nội dung đoạn sau bảng

Có thể viết lại như sau:

```text
Compared with prior FPGA FFT accelerators that primarily focus on generic transform throughput or vendor IP configurations, this work targets a compact and fully verifiable RGB image-processing baseline on Zynq-7000. The design emphasizes transparent HLS implementation, fixed-point bit-width exploration, twiddle lookup optimization, and multi-level verification against a NumPy reference.
```

Nếu paper viết tiếng Việt:

```text
So với các công trình tăng tốc FFT trên FPGA thường tập trung vào thông lượng hoặc cấu hình IP tổng quát, bài báo này hướng đến một baseline nhỏ gọn và dễ kiểm chứng cho xử lý ảnh RGB trên Zynq-7000. Thiết kế nhấn mạnh hiện thực HLS rõ ràng, khảo sát bit-width fixed-point, tối ưu bảng tra twiddle và kiểm chứng nhiều tầng so với tham chiếu NumPy.
```

---

## 6. Sửa Fig. 1 — Kiến trúc tổng quan Zynq

Fig. 1 là hình quan trọng nhất. Hiện hình nhìn hơi giống slide/block diagram đơn giản, chưa đủ “paper architecture”.

### Vấn đề hiện tại

- Chưa thể hiện AXI Interconnect/SmartConnect.
- Chưa thể hiện DDR controller hoặc HP/GP port.
- Chưa thể hiện rõ HLS IP có các cổng:
  - `s_axi_control`
  - `m_axi_input`
  - `m_axi_output_real`
  - `m_axi_output_imag`
- Chưa phân biệt rõ control path và data path.
- Mũi tên còn hơi mơ hồ.
- Nên giảm chữ trong box PS/PL để tránh rối.

### Hình mới nên thể hiện

```text
+------------------------------------------------------------------+
|                          Zynq-7000 SoC                           |
|                                                                  |
|  +-------------------------+        AXI4-Lite       +----------+ |
|  | Processing System (PS)  | ---------------------> | HLS 2D   | |
|  | ARM Cortex-A9           |                        | FFT IP   | |
|  | - Bare-metal control    |                        |          | |
|  | - Cache maintenance     |                        | Row FFT  | |
|  | - Result verification   |                        | Col FFT  | |
|  +-----------+-------------+                        | Twiddle  | |
|              |                                      | LUT      | |
|              | AXI GP/HP                             +----+-----+ |
|              v                                           |       |
|  +-------------------------+                             | m_axi |
|  | AXI Interconnect /      | <---------------------------+       |
|  | DDR Controller          |                                     |
|  +-----------+-------------+                                     |
|              |                                                   |
|              v                                                   |
|  +------------------------------------------------------------+  |
|  | DDR Memory                                                  |  |
|  | Input RGB buffer | Output Real buffer | Output Imag buffer  |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
```

### Caption đề xuất

```text
Fig. 1. Overall architecture of the proposed Zynq-7000 RGB 2D FFT accelerator. The PS configures the HLS IP through AXI4-Lite, while the accelerator accesses input and output buffers in DDR through memory-mapped AXI master ports.
```

Tiếng Việt:

```text
Fig. 1. Kiến trúc tổng quan của bộ tăng tốc 2D FFT RGB trên Zynq-7000. PS cấu hình IP HLS thông qua AXI4-Lite, trong khi bộ tăng tốc truy cập các bộ đệm đầu vào/đầu ra trong DDR bằng các cổng AXI master memory-mapped.
```

### Yêu cầu khi vẽ lại

- Không dùng screenshot cho Fig. 1.
- Vẽ bằng TikZ/vector để khi zoom không vỡ.
- Hình nên full-column hoặc double-column tùy layout.
- Dùng ít màu hoặc grayscale để hợp IEEE.
- Label mũi tên rõ:
  - `AXI4-Lite control`
  - `AXI master read/write`
  - `DDR buffers`
- Nếu dùng tiếng Việt, giữ thuật ngữ kỹ thuật nhất quán.

---

## 7. Sửa Fig. 2 — Luồng xử lý RGB

### Vấn đề hiện tại

Fig. 2 đúng ý nhưng flow hơi tuyến tính quá. Phần “So sánh NumPy” và “Hiển thị log magnitude” nên tách thành hai nhánh vì kiểm chứng định lượng và hiển thị trực quan không cùng vai trò.

### Hình đề xuất

```text
RGB 64×64 Image
        |
        v
Channel Separation
   /      |      \
  R       G       B
  |       |       |
2D FFT  2D FFT  2D FFT
  \       |       /
        v
Real/Imag Coefficient Buffers
      /             \
     v               v
NumPy Error Metrics   Optional Log-Magnitude Visualization
(MAE, MaxAbs)         (visual inspection only)
```

### Caption đề xuất

```text
Fig. 2. RGB image-processing flow. The real and imaginary FFT coefficients are used for quantitative verification, whereas log-magnitude spectra are used only for visual inspection.
```

---

## 8. Sửa Fig. 3 — Datapath nội bộ

### Vấn đề hiện tại

Fig. 3 còn quá tổng quát. Cần làm rõ:

- FFT hàng và FFT cột chạy cho từng kênh.
- Có bộ đệm phức trung gian.
- Twiddle LUT dùng cho butterfly.
- Output tách real/imag.
- Nếu xử lý R/G/B tuần tự, phải thể hiện rõ là `channel loop`, không làm người đọc tưởng ba kênh chạy song song.

### Hình đề xuất

```text
For each channel ch ∈ {R, G, B}

Input channel buffer
        |
        v
Row-wise 1D radix-2 FFT
        |
        v
Intermediate complex buffer
        |
        v
Column-wise 1D radix-2 FFT
        |
        v
Output real/imag buffers

Twiddle ROM/LUT feeds row FFT and column FFT butterflies.
```

### Caption đề xuất

```text
Fig. 3. Internal row-column 2D FFT datapath. The same datapath is reused for the R, G, and B channels in the baseline design.
```

Nếu ba kênh xử lý tuần tự:

```text
The same datapath is reused sequentially for the R, G, and B channels.
```

Nếu ba kênh xử lý song song thì phải đổi thành:

```text
Three identical datapaths are instantiated for parallel R/G/B processing.
```

Chỉ chọn một câu đúng với code thật.

---

## 9. Sửa Fig. 4 — Luồng kiểm chứng

Fig. 4 hiện ổn nhưng nên làm flow một chiều rõ hơn.

### Hình đề xuất

```text
Python NumPy Reference
        ↓
C++ Desktop Testbench
        ↓
HLS C Simulation
        ↓
HLS C Synthesis
        ↓
C/RTL Co-Simulation
        ↓
Vivado Implementation
        ↓
Vitis/Zynq Execution
```

### Caption đề xuất

```text
Fig. 4. Multi-level verification flow used to validate the accelerator from algorithm-level reference generation to RTL co-simulation and Zynq execution.
```

### Lưu ý

Nếu chưa thật sự chạy trên board Zynq thì đừng ghi `Zynq execution` như đã hoàn tất. Khi đó đổi thành:

```text
Vitis/Zynq integration
```

hoặc:

```text
Vivado/Vitis platform integration
```

---

## 10. Fig. 5 — Resource utilization bar chart

### Nhận xét

Fig. 5 không sai, nhưng hơi thừa vì Table III đã có số liệu. Nếu cần tiết kiệm trang, có thể bỏ Fig. 5.

### Nếu giữ

- Ghi rõ chart dựa trên HLS hay Vivado.
- Caption phải nói rõ scope.
- Nên dùng grayscale hoặc hatch pattern thay vì màu mạnh.
- Ghi giá trị lên cột nếu có thể.

### Caption đề xuất

```text
Fig. 5. FPGA resource utilization of the selected fixed-point configuration based on HLS synthesis for the FFT IP.
```

Nếu là Vivado system-level thì đổi thành:

```text
based on post-implementation system report.
```

---

## 11. Fig. 6 — Vivado utilization screenshot

### Nhận xét

Screenshot Vivado hiện không phù hợp lắm cho paper:

- Chữ nhỏ.
- Nhiều chi tiết GUI không cần.
- Chiếm nhiều diện tích.
- Dễ gây rối vì số liệu wrapper khác số liệu HLS IP.

### Đề xuất tốt hơn

Thay screenshot bằng bảng tự dựng:

```latex
\begin{table}[t]
\caption{Post-Implementation System Utilization}
\label{tab:vivado_system_utilization}
\centering
\begin{tabular}{lccc}
\hline
Resource & Used & Available & Utilization \\
\hline
LUT & ... & 53200 & ... \\
FF & ... & 106400 & ... \\
BRAM\_18K & ... & 280 & ... \\
DSP & 8 & 220 & 3.6\% \\
\hline
\end{tabular}
\end{table}
```

### Đoạn giải thích nên thêm

```text
The HLS report and the Vivado post-implementation report have different scopes. The HLS report describes the FFT accelerator IP, whereas the Vivado report includes the complete system wrapper, including the Processing System, AXI interconnect, reset logic, and optional debug logic. Therefore, the two reports should not be compared entry by entry.
```

Tiếng Việt:

```text
Báo cáo HLS và báo cáo Vivado sau implementation có phạm vi khác nhau. Báo cáo HLS phản ánh riêng IP FFT, trong khi báo cáo Vivado bao gồm toàn bộ system wrapper như Processing System, AXI interconnect, reset logic và các khối debug tùy chọn. Vì vậy, không nên so sánh trực tiếp từng dòng số liệu giữa hai báo cáo này.
```

---

## 12. Fig. 7 — So sánh Runtime sin/cos và Twiddle LUT

### Nhận xét

Đây là hình nên giữ vì nó thể hiện đóng góp chính.

### Cần sửa

- Ghi rõ tài nguyên được chuẩn hóa theo phiên bản `Runtime sin/cos`.
- Đồng bộ số liệu với Table IV.
- Nếu vẽ bar chart, nên thêm label phần trăm.
- Không để chart quá to.

### Caption đề xuất

```text
Fig. 7. Normalized resource comparison between runtime trigonometric computation and the fixed twiddle lookup table implementation. Each resource is normalized to the runtime sin/cos version.
```

### Đoạn giải thích nên giữ

```text
Replacing runtime sin/cos computation with a fixed 64-point twiddle lookup table reduces DSP usage from 186 to 8, corresponding to an approximately 95.7% reduction. The LUT and FF counts are also reduced by more than half, indicating that direct trigonometric function synthesis can dominate the cost of an HLS FFT datapath.
```

---

## 13. Fig. 8 — HLS screenshot before/after

### Nhận xét

Fig. 8 nên bỏ khỏi paper chính nếu không bắt buộc.

Lý do:

- Chữ trong screenshot rất nhỏ.
- Chiếm nhiều diện tích.
- Nhìn giống minh chứng tool trong báo cáo lab.
- Table IV đã truyền tải thông tin tốt hơn.

### Phương án tốt nhất

- Bỏ Fig. 8.
- Giữ Table IV.
- Nếu cần bằng chứng cho thầy, đưa screenshot vào slide hoặc phụ lục riêng, không để trong main paper.

### Nếu bắt buộc giữ

- Crop thật sát vùng totals/resource.
- Không đưa toàn bộ giao diện tool.
- Đặt ảnh nhỏ hơn.
- Caption nói rõ ảnh chỉ có vai trò minh họa xu hướng, bảng mới là số liệu định lượng chính.

---

## 14. Fig. 9 — Timing và power screenshot

### Nhận xét

Nên thay screenshot bằng bảng. Screenshot làm trang 7 bị loãng, chữ nhỏ và chưa đẹp.

### Bảng thay thế đề xuất

```latex
\begin{table}[t]
\caption{Post-Implementation Timing and Power Summary}
\label{tab:timing_power}
\centering
\begin{tabular}{lc}
\hline
Metric & Value \\
\hline
Target clock period & 10 ns \\
Estimated clock period & 7.300 ns \\
WNS & 0.668 ns \\
WHS & 0.012 ns \\
Failed endpoints & 0 \\
Total on-chip power & 1.493 W \\
Dynamic power & 1.355 W \\
Static power & 0.138 W \\
\hline
\end{tabular}
\end{table}
```

### Đoạn giải thích đề xuất

```text
The post-implementation timing report indicates positive slack under the 10 ns clock constraint, with a WNS of 0.668 ns and no failed endpoints. The estimated total on-chip power is 1.493 W, consisting of 1.355 W dynamic power and 0.138 W static power. Since the power report is based on default or vectorless activity estimation, it should be interpreted as a post-implementation estimate rather than a board-level power measurement.
```

Tiếng Việt:

```text
Báo cáo timing sau implementation cho thấy thiết kế đạt timing với ràng buộc clock 10 ns, WNS dương 0.668 ns và không có endpoint thất bại. Công suất on-chip ước lượng là 1.493 W, gồm 1.355 W công suất động và 0.138 W công suất tĩnh. Do báo cáo power dựa trên activity mặc định hoặc vectorless estimation, kết quả này nên được xem là ước lượng sau implementation thay vì phép đo công suất thực tế trên bo mạch.
```

---

## 15. Fig. 10 — Kiểm chứng trực quan

### Nhận xét

Nên giữ Fig. 10 vì nó cho người đọc thấy output trực quan. Nhưng cần làm rõ đây không phải tiêu chí đúng/sai chính.

### Cần sửa

- Phóng to ảnh nếu có thể.
- Caption nói rõ `log-magnitude spectra`.
- Nên đặt full-column nếu ảnh nhỏ quá.
- Nếu phổ không rõ, chọn ảnh checker/gradient có phổ dễ quan sát.

### Caption đề xuất

```text
Fig. 10. Input RGB test image and log-magnitude FFT spectra of the R, G, and B channels. The spectra are used only for visual inspection; quantitative verification is performed on raw real and imaginary FFT coefficients.
```

---

## 16. Làm rõ số liệu HLS IP-level vs Vivado system-level

Hiện paper có thể gây rối vì các con số resource ở nhiều nơi khác nhau:

- Abstract/Table III: `66 BRAM_18K, 8 DSP, 9869 FF, 12375 LUT`.
- Table IV Twiddle LUT: `26 BRAM, 8 DSP, 10313 FF, 12126 LUT`.
- Screenshot Vivado: system wrapper có số liệu khác.

Cần tách scope rõ.

### Bảng đề xuất

```latex
\begin{table}[t]
\caption{Report Scope Clarification}
\label{tab:report_scope}
\centering
\begin{tabular}{lll}
\hline
Report & Scope & Used for \\
\hline
HLS synthesis & FFT IP only & Latency/resource exploration \\
C/RTL co-simulation & FFT IP RTL & Functional verification and RTL latency \\
Vivado implementation & Full system wrapper & Timing, system resource, power \\
\hline
\end{tabular}
\end{table}
```

### Đoạn cần thêm

```text
To avoid ambiguity, resource results are reported with their corresponding scope. HLS synthesis results describe the accelerator IP generated from the top function, while Vivado post-implementation results describe the complete Zynq system after integration. Unless otherwise stated, latency values are taken from C/RTL co-simulation and resource values in the design-space exploration are taken from HLS synthesis.
```

---

## 17. Làm rõ PASS/FAIL của fixed-point

Bảng fixed-point hiện có vấn đề: `ap_fixed<28,20>` PASS dù MaxAbs có thể lên tới khoảng 390. Người đọc sẽ hỏi tại sao sai số lớn vậy vẫn pass.

### Cần thêm tiêu chí PASS

Trước Table V, thêm đoạn:

```text
A fixed-point configuration is marked as PASS when all test samples complete without overflow-induced failure and the error metrics remain below the predefined tolerance used in the C++/HLS testbench. The tolerance is applied to the raw real and imaginary FFT coefficients rather than to the log-magnitude visualization.
```

Tiếng Việt:

```text
Một cấu hình fixed-point được đánh dấu PASS khi tất cả mẫu kiểm thử hoàn tất mà không phát sinh lỗi do tràn/bão hòa nghiêm trọng và các thước đo sai số nằm dưới ngưỡng dung sai được định nghĩa trong testbench C++/HLS. Ngưỡng này được áp dụng trên hệ số FFT thực và ảo thô, không áp dụng trên ảnh log-magnitude.
```

### Cần ghi rõ ngưỡng

Agent cần tìm trong code/testbench xem ngưỡng PASS là bao nhiêu. Nếu không có, cần thêm vào paper:

```text
The tolerance was set to ...
```

Nếu chưa có tiêu chí cụ thể, không nên dùng PASS/FAIL quá mạnh. Có thể đổi thành:

```text
Accepted / Rejected
```

hoặc:

```text
Selected / Not selected
```

### Nên thêm normalized error

Thêm cột:

```text
Worst normalized MaxAbs (%)
```

Công thức:

```text
Normalized MaxAbs = MaxAbs / max(|F_ref|) × 100%
```

Điều này giúp người đọc hiểu MaxAbs 390 là lớn hay nhỏ so với dải động FFT.

---

## 18. Thêm software baseline / speedup

Paper dùng từ “accelerator”, vì vậy nên có so sánh với software. Nếu chưa có thì paper vẫn thiếu một mảng quan trọng.

### Bảng đề xuất

```latex
\begin{table}[t]
\caption{Software and Hardware Execution Time Comparison}
\label{tab:speedup}
\centering
\begin{tabular}{lccc}
\hline
Implementation & Platform & Time/frame & Speedup \\
\hline
Software C FFT & ARM Cortex-A9 & ... ms & 1.0$\times$ \\
HLS accelerator & PL @ 100 MHz & 12.6 ms & ...$\times$ \\
\hline
\end{tabular}
\end{table}
```

### Nếu chưa đo được trên board

Không được bịa số. Thay bằng câu trung thực:

```text
The current evaluation reports RTL-estimated accelerator latency from C/RTL co-simulation. A complete ARM software baseline and board-level runtime measurement will be added in future work.
```

Tiếng Việt:

```text
Đánh giá hiện tại báo cáo độ trễ ước lượng ở mức RTL từ C/RTL co-simulation. So sánh thời gian chạy với baseline phần mềm trên ARM và phép đo runtime trực tiếp trên bo mạch sẽ được bổ sung trong hướng phát triển tiếp theo.
```

### Nếu có thể đo nhanh

Nên đo:

1. C implementation chạy trên ARM Cortex-A9.
2. HLS accelerator runtime trên board bằng timer.
3. Tính speedup:
```text
speedup = software_time / accelerator_time
```

---

## 19. Thêm pseudocode / Algorithm 1

Thêm một thuật toán ngắn sẽ làm paper chuyên nghiệp hơn.

### Pseudocode đề xuất

```latex
\begin{algorithm}[t]
\caption{RGB 2D FFT Acceleration}
\label{alg:rgb_fft}
\begin{algorithmic}[1]
\Require Input RGB image $I[3][64][64]$
\Ensure Real and imaginary FFT outputs $Y_R$, $Y_I$
\For{$ch \in \{R,G,B\}$}
    \For{each row $r$}
        \State Compute 1D radix-2 FFT of $I[ch][r][:]$
    \EndFor
    \State Store row FFT results in intermediate complex buffer
    \For{each column $c$}
        \State Compute 1D radix-2 FFT of the intermediate column
    \EndFor
    \State Write real and imaginary coefficients to output buffers
\EndFor
\end{algorithmic}
\end{algorithm}
```

Nếu không muốn dùng package algorithm, có thể viết bằng text/pseudocode đơn giản.

---

## 20. Thêm HLS interface/pragmas

Paper nên có một đoạn nói rõ interface HLS. Hiện có hàm top nhưng chưa đủ thông tin về `m_axi` và `s_axilite`.

### Đoạn đề xuất

```text
The HLS top function exposes memory-mapped AXI master ports for the input, real-output, and imaginary-output buffers, and an AXI4-Lite control interface for configuration and status registers. This interface allows the PS to provide DDR buffer addresses, start the accelerator, and poll the completion status.
```

Tiếng Việt:

```text
Hàm top HLS sử dụng các cổng AXI master memory-mapped cho bộ đệm đầu vào, đầu ra phần thực và đầu ra phần ảo, đồng thời sử dụng giao tiếp AXI4-Lite cho các thanh ghi cấu hình và trạng thái. Cách tổ chức này cho phép PS cung cấp địa chỉ bộ đệm DDR, khởi động accelerator và polling trạng thái hoàn tất.
```

### Code snippet ngắn nếu có chỗ

```cpp
#pragma HLS INTERFACE m_axi     port=input       offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi     port=output_real offset=slave bundle=gmem1
#pragma HLS INTERFACE m_axi     port=output_imag offset=slave bundle=gmem2
#pragma HLS INTERFACE s_axilite port=input       bundle=control
#pragma HLS INTERFACE s_axilite port=output_real bundle=control
#pragma HLS INTERFACE s_axilite port=output_imag bundle=control
#pragma HLS INTERFACE s_axilite port=return      bundle=control
```

Chỉ đưa code nếu đúng với code thật.

---

## 21. Giải thích vì sao chọn 64×64

Hiện người đọc có thể hỏi vì sao chỉ dùng ảnh 64×64. Cần giải thích trước khi bị hỏi.

### Đoạn đề xuất

```text
The 64×64 resolution is selected as a fixed-size baseline for three reasons. First, it is a power-of-two size suitable for radix-2 FFT decomposition. Second, it keeps the on-chip buffer size and verification cost manageable during the initial Zynq/HLS integration stage. Third, it provides a compact test case for evaluating fixed-point behavior, twiddle lookup optimization, and PS/PL memory-mapped communication before scaling the design to larger images.
```

Tiếng Việt:

```text
Kích thước 64×64 được chọn làm baseline cố định vì ba lý do. Thứ nhất, đây là kích thước lũy thừa của hai, phù hợp với phân rã FFT radix-2. Thứ hai, kích thước này giữ dung lượng bộ đệm nội bộ và chi phí kiểm chứng ở mức dễ kiểm soát trong giai đoạn tích hợp Zynq/HLS ban đầu. Thứ ba, đây là trường hợp thử nghiệm nhỏ gọn để đánh giá hành vi fixed-point, tối ưu twiddle LUT và giao tiếp memory-mapped PS/PL trước khi mở rộng lên ảnh kích thước lớn hơn.
```

---

## 22. Giải thích vì sao chọn memory-mapped baseline

### Đoạn đề xuất

```text
A memory-mapped architecture is used in the baseline implementation to simplify verification and integration. Compared with a streaming architecture, the memory-mapped design allows the PS to explicitly manage input and output buffers in DDR and makes it straightforward to compare accelerator outputs against stored NumPy reference data. AXI Stream and AXI DMA are left as future extensions for higher-throughput or continuous video processing.
```

Tiếng Việt:

```text
Kiến trúc memory-mapped được sử dụng trong phiên bản baseline nhằm đơn giản hóa kiểm chứng và tích hợp. So với kiến trúc streaming, thiết kế memory-mapped cho phép PS quản lý trực tiếp các bộ đệm đầu vào/đầu ra trong DDR và thuận tiện so sánh kết quả accelerator với dữ liệu tham chiếu NumPy đã lưu. AXI Stream và AXI DMA được xem là hướng mở rộng cho các phiên bản yêu cầu thông lượng cao hơn hoặc xử lý video liên tục.
```

---

## 23. Sửa abstract

Abstract hiện có nhiều thông tin tốt, nhưng hơi dài và có vẻ nhồi nhiều số liệu. Sau khi sửa, abstract nên:

1. Nêu bài toán.
2. Nêu thiết kế.
3. Nêu điểm tối ưu chính.
4. Nêu kiểm chứng.
5. Nêu kết quả chính.

### Abstract tiếng Việt đề xuất

```text
Biến đổi Fourier nhanh hai chiều (2D FFT) là phép toán quan trọng trong xử lý ảnh miền tần số nhưng có thể tạo ra chi phí tính toán lớn trên các bộ xử lý nhúng, đặc biệt khi xử lý ảnh màu RGB. Bài báo này trình bày một bộ tăng tốc 2D FFT cho ảnh RGB 64×64 trên nền tảng FPGA Zynq-7000. Thiết kế được hiện thực bằng Vitis HLS theo phương pháp FFT hàng-cột radix-2, sử dụng kiểu số cố định ap_fixed<28,20> và bảng tra twiddle 64 điểm để tránh tổng hợp các phép lượng giác runtime. Trong mô hình đồng thiết kế phần cứng/phần mềm, Processing System cấu hình IP, quản lý bộ đệm DDR và kiểm tra kết quả so với tham chiếu Python NumPy. Kết quả C/RTL co-simulation và implementation cho thấy thiết kế đạt độ trễ RTL 1,260,411 chu kỳ cho mỗi frame RGB 64×64, đáp ứng ràng buộc clock 10 ns, sử dụng 8 DSP và duy trì mức sử dụng LUT/BRAM trong giới hạn của xc7z020clg400-1. Kết quả cho thấy kiến trúc đề xuất là một baseline tiết kiệm tài nguyên và dễ kiểm chứng cho xử lý ảnh RGB trong miền tần số trên FPGA.
```

### Lưu ý

Nếu số liệu `66 BRAM_18K, 9869 FF, 12375 LUT` là HLS IP-level, cần nói rõ trong abstract hoặc chỉ để các số quan trọng nhất như DSP/latency/timing. Abstract không nên gây rối bởi nhiều số liệu khác scope.

---

## 24. Sửa contribution list

Contribution list hiện ổn, nhưng có thể làm sắc hơn.

### Contribution list đề xuất

```text
Các đóng góp chính của bài báo gồm:
1. Đề xuất và hiện thực một baseline bộ tăng tốc 2D FFT cho ảnh RGB 64×64 trên Zynq-7000 bằng Vitis HLS.
2. Xây dựng datapath FFT hàng-cột radix-2 sử dụng số cố định và bảng tra twiddle 64 điểm.
3. Đánh giá ảnh hưởng của tối ưu twiddle LUT, cho thấy số DSP giảm từ 186 xuống 8 so với phiên bản tính sin/cos runtime.
4. Khảo sát nhiều cấu hình fixed-point để lựa chọn định dạng ap_fixed<28,20> cho baseline.
5. Kiểm chứng thiết kế bằng luồng nhiều tầng gồm NumPy reference, C++ testbench, HLS C simulation, C/RTL co-simulation và implementation trên hệ Zynq.
```

Lưu ý: Nếu chưa thật sự chạy trên board, không ghi “execution on Zynq” quá mạnh.

---

## 25. Sửa văn phong

### Tránh các cụm quá giống báo cáo project

Nên đổi:

```text
Dự án sử dụng...
Ảnh chụp Vivado bổ sung góc nhìn...
bằng chứng hỗ trợ từ tool...
```

Thành:

```text
Luồng kiểm chứng được xây dựng...
Báo cáo sau implementation được sử dụng để xác nhận...
Các số liệu định lượng chính được tổng hợp trong bảng...
```

### Một số câu nên sửa

#### Câu hiện tại

```text
Ảnh chụp Vivado ở Hình ?? bổ sung góc nhìn sau implementation bên cạnh ước lượng HLS ở Bảng ??.
```

#### Sửa thành

```text
Báo cáo sau implementation được sử dụng để đánh giá tài nguyên ở cấp hệ thống sau khi tích hợp PS, interconnect và IP FFT. Do phạm vi báo cáo khác với HLS synthesis, các số liệu này được trình bày riêng và không được so sánh trực tiếp từng dòng với tài nguyên của riêng IP FFT.
```

#### Câu hiện tại

```text
Hình ?? cho thấy bằng chứng trực tiếp từ giao diện báo cáo HLS trong quá trình tối ưu.
```

#### Sửa thành

```text
Kết quả trong Table~\ref{tab:twiddle_optimization} cho thấy tác động của tối ưu twiddle LUT lên tài nguyên phần cứng.
```

---

## 26. Thống nhất thuật ngữ

Cần chọn một kiểu và dùng nhất quán.

### Thuật ngữ nên dùng

| Thuật ngữ | Khuyến nghị |
|---|---|
| fixed-point | số cố định hoặc fixed-point, chọn một cách |
| memory-mapped | memory-mapped, giữ tiếng Anh |
| AXI master | AXI master, giữ tiếng Anh |
| AXI4-Lite | AXI4-Lite |
| datapath | datapath hoặc đường dữ liệu, chọn một cách |
| baseline | thiết kế cơ sở hoặc baseline, chọn một cách |
| co-simulation | C/RTL co-simulation |
| implementation | implementation hoặc triển khai sau tổng hợp, dùng nhất quán |

Khuyến nghị thực tế: vì paper kỹ thuật FPGA, có thể giữ các thuật ngữ Anh như `fixed-point`, `memory-mapped`, `datapath`, `baseline`, `co-simulation`, `implementation`. Nhưng nên giải thích lần đầu.

---

## 27. Định dạng code và kiểu dữ liệu

Các từ sau nên dùng `\texttt{}` trong LaTeX:

```latex
\texttt{ap\_fixed<28,20>}
\texttt{fft2d\_fixed\_top}
\texttt{sin/cos}
\texttt{square}
\texttt{gradient}
\texttt{checker}
\texttt{circle}
\texttt{NumPy}
\texttt{fft2}
```

### Lỗi cần tránh

Caption IEEE thường uppercase table caption, làm `ap_fixed` bị hỏng. Không nên để `ap_fixed<28,20>` trực tiếp trong table caption nếu nó bị auto-uppercase.

Thay:

```text
ĐỘ CHÍNH XÁC VÀ ĐỘ TRỄ RTL VỚI AP_FIXED<28,20>
```

Bằng:

```text
Độ chính xác và độ trễ RTL với định dạng fixed-point 28/20
```

Trong nội dung bảng/cột thì có thể ghi `ap_fixed<28,20>`.

---

## 28. Bảng tài nguyên nên chuẩn hóa

### Table III hiện tại

Có thể giữ, nhưng cần nói rõ scope:

```text
Table III. HLS IP Resource Utilization of the Selected Configuration
```

hoặc tiếng Việt:

```text
Table III. Mức sử dụng tài nguyên HLS của IP FFT với cấu hình được chọn
```

### Bảng đề xuất

```latex
\begin{table}[t]
\caption{HLS IP Resource Utilization of the Selected Configuration}
\label{tab:hls_resource}
\centering
\begin{tabular}{lccc}
\hline
Resource & Used & Available & Utilization \\
\hline
BRAM\_18K & 66 & 280 & 23\% \\
DSP & 8 & 220 & 3\% \\
FF & 9869 & 106400 & 9\% \\
LUT & 12375 & 53200 & 23\% \\
\hline
\end{tabular}
\end{table}
```

### Lưu ý

Nếu `Available` là tài nguyên toàn chip nhưng `Used` là IP-level HLS estimate, cần nói rõ đây là so sánh tương đối với chip target, không phải full system post-implementation.

---

## 29. Table IV Twiddle LUT

### Bảng hiện tại

```text
Runtime sin/cos  42  186  20509  29674
Twiddle LUT      26  8    10313  12126
```

Rất tốt, nên giữ.

### Nên thêm cột reduction

```latex
\begin{table}[t]
\caption{Effect of Twiddle LUT Optimization}
\label{tab:twiddle_optimization}
\centering
\begin{tabular}{lcccc}
\hline
Version & BRAM & DSP & FF & LUT \\
\hline
Runtime sin/cos & 42 & 186 & 20509 & 29674 \\
Twiddle LUT & 26 & 8 & 10313 & 12126 \\
Reduction & 38.1\% & 95.7\% & 49.7\% & 59.1\% \\
\hline
\end{tabular}
\end{table}
```

Tính reduction:
- BRAM: `(42-26)/42 = 38.1%`
- DSP: `(186-8)/186 = 95.7%`
- FF: `(20509-10313)/20509 ≈ 49.7%`
- LUT: `(29674-12126)/29674 ≈ 59.1%`

---

## 30. Table V fixed-point sweep

### Vấn đề

Bảng tốt nhưng cần bổ sung:

- PASS criterion.
- Normalized error nếu có thể.
- Giải thích vì sao `ap_fixed<28,20>` chọn thay vì `ap_fixed<32,20>`.

### Đoạn giải thích đề xuất sau bảng

```text
Although ap_fixed<32,20> provides lower error, ap_fixed<28,20> is selected because it passes all test samples while using a narrower word length. Configurations with fewer integer bits fail because the 64×64 FFT can produce large intermediate and DC coefficients, making integer range more critical than fractional precision for this baseline.
```

Tiếng Việt:

```text
Mặc dù ap_fixed<32,20> cho sai số thấp hơn, ap_fixed<28,20> được chọn vì vượt qua tất cả mẫu kiểm thử trong khi sử dụng tổng độ rộng bit nhỏ hơn. Các cấu hình có ít bit phần nguyên thất bại do FFT 64×64 có thể sinh ra các hệ số trung gian và hệ số DC lớn; vì vậy, dải biểu diễn phần nguyên quan trọng hơn việc chỉ tăng độ chính xác phần thập phân trong baseline này.
```

---

## 31. Table VI Accuracy and Latency

### Vấn đề

Caption đang lỗi format. Cần sửa.

### Caption đề xuất

```text
Table VI. RTL Accuracy and Latency of the Selected Fixed-Point Configuration
```

hoặc:

```text
Table VI. Độ chính xác và độ trễ RTL của cấu hình fixed-point được chọn
```

Không để `ap_fixed<28,20>` trong caption nếu IEEE làm uppercase lỗi.

### Đoạn giải thích nên thêm

```text
The RTL latency is identical for all samples because the input size and loop bounds are fixed. At 100 MHz, 1,260,411 cycles correspond to approximately 12.6 ms per RGB frame.
```

Tiếng Việt:

```text
Độ trễ RTL giống nhau cho tất cả mẫu vì kích thước đầu vào và giới hạn vòng lặp là cố định. Ở tần số 100 MHz, 1,260,411 chu kỳ tương đương khoảng 12.6 ms cho mỗi frame RGB.
```

---

## 32. Timing/power section

### Cần làm rõ

- Timing/power là post-implementation estimate.
- Power không phải đo thực tế trên board.
- Nếu dùng activity mặc định/vectorless, phải ghi rõ.

### Đoạn đề xuất

```text
Post-implementation timing and power reports are used to assess implementation feasibility. The design satisfies the 10 ns clock constraint with positive slack. However, the reported power is an estimation based on the implementation tool and default switching activity; therefore, it should not be interpreted as a measured board-level power result.
```

---

## 33. Discussion section nên chỉnh

Discussion hiện tốt nhưng có thể làm sắc hơn.

### Cấu trúc discussion đề xuất

1. Tác động của twiddle LUT.
2. Ý nghĩa của fixed-point bit-width.
3. Tính khả thi sau implementation.
4. Giới hạn hiện tại.
5. Hướng mở rộng.

### Đoạn discussion gợi ý

```text
The results indicate that the proposed HLS accelerator provides a compact and verifiable baseline for RGB 2D FFT processing on Zynq-7000. The largest resource reduction comes from replacing runtime trigonometric computation with a fixed twiddle lookup table. This confirms that mathematical library calls in HLS should be carefully reviewed when targeting small FPGA devices.

The fixed-point sweep shows that integer range is a dominant factor for the 64×64 FFT. Configurations with insufficient integer bits fail even when fractional precision is available, because the transform can generate large intermediate and DC coefficients. The selected ap_fixed<28,20> format provides a practical trade-off between precision and word length for the tested inputs.

The current design still has several limitations. It supports only a fixed 64×64 image size, uses a memory-mapped baseline interface, and processes the RGB channels without aggressive parallelism. In addition, the current evaluation focuses on synthetic test patterns and RTL-level latency. More natural images, board-level runtime measurements, and software baseline comparisons are needed for a more complete performance evaluation.
```

---

## 34. Conclusion nên chỉnh

Conclusion nên ngắn, không lặp quá nhiều số liệu.

### Conclusion đề xuất

```text
This paper presented a resource-efficient RGB 2D FFT accelerator for Zynq-7000 FPGA. The accelerator was implemented in Vitis HLS using a row-column radix-2 FFT structure, fixed-point arithmetic, and a 64-point twiddle lookup table. Multi-level verification against a NumPy reference confirmed the correctness of the generated real and imaginary FFT coefficients. The selected configuration achieved an RTL latency of 1,260,411 cycles per RGB 64×64 frame and significantly reduced DSP usage compared with runtime sin/cos computation.

Future work will focus on increasing throughput through AXI DMA or AXI Stream interfaces, deeper pipelining, parallel RGB channel processing, support for larger image sizes, and board-level runtime/power measurements.
```

Tiếng Việt:

```text
Bài báo đã trình bày một bộ tăng tốc 2D FFT cho ảnh RGB trên FPGA Zynq-7000 theo hướng tiết kiệm tài nguyên và dễ kiểm chứng. Bộ tăng tốc được hiện thực bằng Vitis HLS với cấu trúc FFT radix-2 hàng-cột, số cố định và bảng tra twiddle 64 điểm. Luồng kiểm chứng nhiều tầng so với tham chiếu NumPy xác nhận tính đúng của các hệ số FFT phần thực và phần ảo. Cấu hình được chọn đạt độ trễ RTL 1,260,411 chu kỳ cho mỗi frame RGB 64×64 và giảm đáng kể số DSP so với phiên bản tính sin/cos runtime.

Các hướng phát triển tiếp theo gồm tăng thông lượng bằng AXI DMA hoặc AXI Stream, pipeline sâu hơn, xử lý song song các kênh RGB, hỗ trợ kích thước ảnh lớn hơn và đo runtime/công suất trực tiếp trên bo mạch.
```

---

## 35. Giữ paper dưới 10 trang

Hiện paper 7 trang nhưng chưa có references. Sau khi sửa nên nhắm 8–9 trang, không cần cố đủ 10 trang.

### Đề xuất phân bổ trang

| Phần | Độ dài khuyến nghị |
|---|---|
| Abstract + Introduction | 1.2–1.5 trang |
| Background + Related Work | 1.0–1.3 trang |
| Architecture + Implementation | 2.0 trang |
| Experimental Setup + Results | 2.5–3.0 trang |
| Discussion + Conclusion | 1.0 trang |
| References | 0.5–1.0 trang |

### Nên bỏ/giảm để tiết kiệm trang

- Bỏ Fig. 8 screenshot HLS.
- Thay Fig. 9 screenshot bằng bảng.
- Cân nhắc bỏ Fig. 5 nếu Table III đã đủ.
- Không để screenshot chiếm nửa trang.
- Không lặp lại số liệu giống nhau ở nhiều nơi.

---

## 36. Checklist cuối trước khi nộp

### Nội dung

- [ ] Có problem statement rõ.
- [ ] Có contribution rõ.
- [ ] Có related work và comparison table.
- [ ] Có architecture figure đẹp.
- [ ] Có implementation details đủ kỹ thuật.
- [ ] Có experimental setup đầy đủ: board, part, tool, clock, input size, data type, test samples, metrics.
- [ ] Có resource utilization.
- [ ] Có timing.
- [ ] Có power estimate.
- [ ] Có latency.
- [ ] Có accuracy metrics.
- [ ] Có discussion về limitation.
- [ ] Có future work thực tế.

### Format

- [ ] Không còn `[?]`.
- [ ] Không còn `Hình ??`.
- [ ] Không còn `Bảng ??`.
- [ ] Không còn `(??)`.
- [ ] Tất cả hình có caption + label.
- [ ] Tất cả bảng có caption + label.
- [ ] Tất cả công thức có label nếu được gọi lại.
- [ ] References đầy đủ.
- [ ] Tên hình/bảng nhất quán.
- [ ] Không có screenshot chữ quá nhỏ.
- [ ] Không có caption bị lỗi uppercase.
- [ ] Không có dòng/cột bảng tràn layout.
- [ ] Không vượt 10 trang.

### Tính trung thực số liệu

- [ ] Không gọi kết quả là “board-level measurement” nếu chỉ là HLS/Cosim/Vivado estimate.
- [ ] Không ghi speedup nếu chưa đo software baseline.
- [ ] Không so sánh trực tiếp HLS IP-level với Vivado system-level nếu không giải thích scope.
- [ ] Power phải ghi là estimated nếu chưa đo thực tế.
- [ ] Nếu chưa chạy thật trên board, dùng từ `integration` thay vì `execution`.

---

## 37. Prompt ngắn để đưa cho agent sửa paper

Có thể đưa nguyên prompt này cho agent:

```text
Bạn hãy sửa file LaTeX paper IEEE của tôi theo checklist trong markdown này. Ưu tiên:
1. Fix toàn bộ citation/cross-reference lỗi `[?]`, `Hình ??`, `Bảng ??`, `(??)`.
2. Thêm References và đảm bảo BibTeX compile đúng.
3. Vẽ lại Fig. 1 architecture bằng TikZ/vector theo mô tả PS/PL/AXI/DDR/HLS IP.
4. Thay các screenshot Vivado/Vitis HLS khó đọc bằng bảng sạch nếu có đủ số liệu.
5. Tách rõ HLS IP-level report và Vivado system-level report.
6. Thêm tiêu chí PASS/FAIL cho fixed-point sweep.
7. Thêm bảng related work/comparison.
8. Thêm hoặc chừa placeholder cho software baseline/speedup; không được bịa số.
9. Giữ paper tối đa 10 trang.
10. Không thay đổi số liệu kỹ thuật nếu không có căn cứ; nếu thiếu số liệu thì để TODO rõ ràng.
```

---

## 38. Kết luận cho agent

Mục tiêu không phải viết dài hơn, mà là làm paper nhìn **sạch, có căn cứ, đúng chuẩn IEEE và dễ bảo vệ**. Tập trung sửa những thứ khiến bài bị nhìn như draft: reference lỗi, hình screenshot nhỏ, architecture chưa rõ, scope số liệu chưa tách bạch và thiếu software baseline.
