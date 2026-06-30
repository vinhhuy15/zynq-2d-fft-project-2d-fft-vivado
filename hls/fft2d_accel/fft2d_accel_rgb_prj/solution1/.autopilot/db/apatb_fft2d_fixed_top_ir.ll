; ModuleID = 'D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/fft2d_accel_rgb_prj/solution1/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.ap_fixed<32, 20, AP_RND, AP_SAT>" = type { %"struct.ap_fixed_base<32, 20, true, AP_RND, AP_SAT>" }
%"struct.ap_fixed_base<32, 20, true, AP_RND, AP_SAT>" = type { %"struct.ssdm_int<32, true>" }
%"struct.ssdm_int<32, true>" = type { i32 }

; Function Attrs: noinline
define void @apatb_fft2d_fixed_top_ir([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="3" "maxi" %input, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull "fpga.decayed.dim.hint"="3" "maxi" %output_real, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull "fpga.decayed.dim.hint"="3" "maxi" %output_imag) local_unnamed_addr #0 {
entry:
  %0 = bitcast [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %input to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  %1 = call i8* @malloc(i64 49152)
  %input_copy = bitcast i8* %1 to [3 x [64 x [64 x i32]]]*
  %2 = bitcast [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %output_real to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  %3 = call i8* @malloc(i64 49152)
  %output_real_copy = bitcast i8* %3 to [3 x [64 x [64 x i32]]]*
  %4 = bitcast [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %output_imag to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  %5 = call i8* @malloc(i64 49152)
  %output_imag_copy = bitcast i8* %5 to [3 x [64 x [64 x i32]]]*
  call fastcc void @copy_in([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* nonnull %0, [3 x [64 x [64 x i32]]]* %input_copy, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* nonnull %2, [3 x [64 x [64 x i32]]]* %output_real_copy, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* nonnull %4, [3 x [64 x [64 x i32]]]* %output_imag_copy)
  call void @apatb_fft2d_fixed_top_hw([3 x [64 x [64 x i32]]]* %input_copy, [3 x [64 x [64 x i32]]]* %output_real_copy, [3 x [64 x [64 x i32]]]* %output_imag_copy)
  call void @copy_back([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %0, [3 x [64 x [64 x i32]]]* %input_copy, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %2, [3 x [64 x [64 x i32]]]* %output_real_copy, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4, [3 x [64 x [64 x i32]]]* %output_imag_copy)
  call void @free(i8* %1)
  call void @free(i8* %3)
  call void @free(i8* %5)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* readonly, [3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* readonly, [3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* readonly, [3 x [64 x [64 x i32]]]*) unnamed_addr #1 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([3 x [64 x [64 x i32]]]* %1, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %0)
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([3 x [64 x [64 x i32]]]* %3, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %2)
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([3 x [64 x [64 x i32]]]* %5, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %src, null
  %1 = icmp eq [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]], [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]], [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %src, i64 0, i64 %for.loop.idx2
  call void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst.addr, [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src.addr, i64 64)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src, null
  %1 = icmp eq [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond7 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond7, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx8 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"], [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"], [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %3 = load i32, i32* %src.addr.0.0.05, align 4
  store i32 %3, i32* %dst.addr.0.0.06, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx8, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_out([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly) unnamed_addr #3 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %0, [3 x [64 x [64 x i32]]]* %1)
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %2, [3 x [64 x [64 x i32]]]* %3)
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4, [3 x [64 x [64 x i32]]]* %5)
  ret void
}

declare i8* @malloc(i64) local_unnamed_addr

declare void @free(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %dst, [3 x [64 x [64 x i32]]]* readonly %src) unnamed_addr #4 {
entry:
  %0 = icmp eq [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %dst, null
  %1 = icmp eq [3 x [64 x [64 x i32]]]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.171"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* nonnull %dst, [3 x [64 x [64 x i32]]]* nonnull %src, i64 3)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.171"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %dst, [3 x [64 x [64 x i32]]]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [3 x [64 x [64 x i32]]]* %src, null
  %1 = icmp eq [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]], [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %dst, i64 0, i64 %for.loop.idx2
  %3 = getelementptr [3 x [64 x [64 x i32]]], [3 x [64 x [64 x i32]]]* %src, i64 0, i64 %for.loop.idx2
  call void @"arraycpy_hls.p0a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.174"([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst.addr, [64 x [64 x i32]]* %3, i64 64)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.174"([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, [64 x [64 x i32]]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x [64 x i32]]* %src, null
  %1 = icmp eq [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]], [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %dst, i64 0, i64 %for.loop.idx2
  %3 = getelementptr [64 x [64 x i32]], [64 x [64 x i32]]* %src, i64 0, i64 %for.loop.idx2
  call void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.177"([64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst.addr, [64 x i32]* %3, i64 64)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.177"([64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, [64 x i32]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x i32]* %src, null
  %1 = icmp eq [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond7 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond7, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx8 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %3 = getelementptr [64 x i32], [64 x i32]* %src, i64 0, i64 %for.loop.idx8
  %dst.addr.0.0.06 = getelementptr [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"], [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %dst, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %4 = load i32, i32* %3, align 4
  store i32 %4, i32* %dst.addr.0.0.06, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx8, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>"([3 x [64 x [64 x i32]]]* %dst, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* readonly %src) unnamed_addr #4 {
entry:
  %0 = icmp eq [3 x [64 x [64 x i32]]]* %dst, null
  %1 = icmp eq [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.184"([3 x [64 x [64 x i32]]]* nonnull %dst, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* nonnull %src, i64 3)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.184"([3 x [64 x [64 x i32]]]* %dst, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %src, null
  %1 = icmp eq [3 x [64 x [64 x i32]]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %3 = getelementptr [3 x [64 x [64 x i32]]], [3 x [64 x [64 x i32]]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]], [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %src, i64 0, i64 %for.loop.idx2
  call void @"arraycpy_hls.p0a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.187"([64 x [64 x i32]]* %3, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %src.addr, i64 64)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.187"([64 x [64 x i32]]* %dst, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %src, null
  %1 = icmp eq [64 x [64 x i32]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %3 = getelementptr [64 x [64 x i32]], [64 x [64 x i32]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]], [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %src, i64 0, i64 %for.loop.idx2
  call void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.190"([64 x i32]* %3, [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src.addr, i64 64)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.190"([64 x i32]* %dst, [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src, null
  %1 = icmp eq [64 x i32]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond7 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond7, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx8 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"], [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]* %src, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %3 = getelementptr [64 x i32], [64 x i32]* %dst, i64 0, i64 %for.loop.idx8
  %4 = load i32, i32* %src.addr.0.0.05, align 4
  store i32 %4, i32* %3, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx8, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

declare void @apatb_fft2d_fixed_top_hw([3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x i32]]]*)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*, [3 x [64 x [64 x i32]]]* readonly) unnamed_addr #3 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %2, [3 x [64 x [64 x i32]]]* %3)
  call fastcc void @"onebyonecpy_hls.p0a3a64a64struct.ap_fixed<32, 20, AP_RND, AP_SAT>.168"([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4, [3 x [64 x [64 x i32]]]* %5)
  ret void
}

declare void @fft2d_fixed_top_hw_stub([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull readonly, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* noalias nocapture nonnull)

define void @fft2d_fixed_top_hw_stub_wrapper([3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x i32]]]*, [3 x [64 x [64 x i32]]]*) #5 {
entry:
  %3 = call i8* @malloc(i64 49152)
  %4 = bitcast i8* %3 to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  %5 = call i8* @malloc(i64 49152)
  %6 = bitcast i8* %5 to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  %7 = call i8* @malloc(i64 49152)
  %8 = bitcast i8* %7 to [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]*
  call void @copy_out([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4, [3 x [64 x [64 x i32]]]* %0, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %6, [3 x [64 x [64 x i32]]]* %1, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %8, [3 x [64 x [64 x i32]]]* %2)
  %9 = bitcast [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4 to [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]*
  %10 = bitcast [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %6 to [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]*
  %11 = bitcast [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %8 to [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]*
  call void @fft2d_fixed_top_hw_stub([64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %9, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %10, [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]* %11)
  call void @copy_in([3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %4, [3 x [64 x [64 x i32]]]* %0, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %6, [3 x [64 x [64 x i32]]]* %1, [3 x [64 x [64 x %"struct.ap_fixed<32, 20, AP_RND, AP_SAT>"]]]* %8, [3 x [64 x [64 x i32]]]* %2)
  call void @free(i8* %3)
  call void @free(i8* %5)
  call void @free(i8* %7)
  ret void
}

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
