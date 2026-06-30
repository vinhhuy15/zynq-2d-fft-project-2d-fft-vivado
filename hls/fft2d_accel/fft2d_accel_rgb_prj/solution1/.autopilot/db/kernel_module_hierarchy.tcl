set ModuleHierarchy {[{
"Name" : "fft2d_fixed_top", "RefName" : "fft2d_fixed_top","ID" : "0","Type" : "sequential",
"SubInsts" : [
	{"Name" : "grp_fft2d_fixed_top_Pipeline_1_fu_206", "RefName" : "fft2d_fixed_top_Pipeline_1","ID" : "1","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "Loop 1","RefName" : "Loop 1","ID" : "2","Type" : "pipeline"},]},
	{"Name" : "grp_fft2d_fixed_top_Pipeline_2_fu_214", "RefName" : "fft2d_fixed_top_Pipeline_2","ID" : "3","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "Loop 1","RefName" : "Loop 1","ID" : "4","Type" : "pipeline"},]},
	{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_180_1_VITIS_LOOP_181_2_VITIS_LOOP_182_3_fu_222", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_180_1_VITIS_LOOP_181_2_VITIS_LOOP_182_3","ID" : "5","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_180_1_VITIS_LOOP_181_2_VITIS_LOOP_182_3","RefName" : "VITIS_LOOP_180_1_VITIS_LOOP_181_2_VITIS_LOOP_182_3","ID" : "6","Type" : "pipeline"},]},
	{"Name" : "grp_fft2d_fixed_top_Outline_VITIS_LOOP_189_4_fu_233", "RefName" : "fft2d_fixed_top_Outline_VITIS_LOOP_189_4","ID" : "7","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_189_4","RefName" : "VITIS_LOOP_189_4","ID" : "8","Type" : "no",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_190_5","RefName" : "VITIS_LOOP_190_5","ID" : "9","Type" : "no",
			"SubInsts" : [
			{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_191_6_fu_65", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_191_6","ID" : "10","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_191_6","RefName" : "VITIS_LOOP_191_6","ID" : "11","Type" : "pipeline"},]},
			{"Name" : "grp_fft1d_fixed_fu_78", "RefName" : "fft1d_fixed","ID" : "12","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_100_1","RefName" : "VITIS_LOOP_100_1","ID" : "13","Type" : "no",
					"SubInsts" : [
					{"Name" : "grp_fft1d_fixed_Pipeline_VITIS_LOOP_103_2_fu_127", "RefName" : "fft1d_fixed_Pipeline_VITIS_LOOP_103_2","ID" : "14","Type" : "sequential",
							"SubLoops" : [
							{"Name" : "VITIS_LOOP_103_2","RefName" : "VITIS_LOOP_103_2","ID" : "15","Type" : "pipeline"},]},]},
					{"Name" : "VITIS_LOOP_117_3","RefName" : "VITIS_LOOP_117_3","ID" : "16","Type" : "no",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_118_4","RefName" : "VITIS_LOOP_118_4","ID" : "17","Type" : "no",
						"SubInsts" : [
						{"Name" : "grp_fft1d_fixed_Pipeline_VITIS_LOOP_119_5_fu_133", "RefName" : "fft1d_fixed_Pipeline_VITIS_LOOP_119_5","ID" : "18","Type" : "sequential",
								"SubLoops" : [
								{"Name" : "VITIS_LOOP_119_5","RefName" : "VITIS_LOOP_119_5","ID" : "19","Type" : "pipeline"},]},]},]},]},
			{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_197_7_fu_90", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_197_7","ID" : "20","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_197_7","RefName" : "VITIS_LOOP_197_7","ID" : "21","Type" : "pipeline"},]},]},]},]},
	{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_217_12_VITIS_LOOP_218_13_VITIS_LOOP_219_14_fu_281", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_217_12_VITIS_LOOP_218_13_VITIS_LOOP_219_14","ID" : "22","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_217_12_VITIS_LOOP_218_13_VITIS_LOOP_219_14","RefName" : "VITIS_LOOP_217_12_VITIS_LOOP_218_13_VITIS_LOOP_219_14","ID" : "23","Type" : "pipeline"},]},],
"SubLoops" : [
	{"Name" : "VITIS_LOOP_203_8","RefName" : "VITIS_LOOP_203_8","ID" : "24","Type" : "no",
	"SubLoops" : [
	{"Name" : "VITIS_LOOP_204_9","RefName" : "VITIS_LOOP_204_9","ID" : "25","Type" : "no",
		"SubInsts" : [
		{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_205_10_fu_247", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_205_10","ID" : "26","Type" : "sequential",
				"SubLoops" : [
				{"Name" : "VITIS_LOOP_205_10","RefName" : "VITIS_LOOP_205_10","ID" : "27","Type" : "pipeline"},]},
		{"Name" : "grp_fft1d_fixed_col_fu_259", "RefName" : "fft1d_fixed_col","ID" : "28","Type" : "sequential",
				"SubLoops" : [
				{"Name" : "VITIS_LOOP_132_1","RefName" : "VITIS_LOOP_132_1","ID" : "29","Type" : "no",
				"SubInsts" : [
				{"Name" : "grp_fft1d_fixed_col_Pipeline_VITIS_LOOP_135_2_fu_127", "RefName" : "fft1d_fixed_col_Pipeline_VITIS_LOOP_135_2","ID" : "30","Type" : "sequential",
						"SubLoops" : [
						{"Name" : "VITIS_LOOP_135_2","RefName" : "VITIS_LOOP_135_2","ID" : "31","Type" : "pipeline"},]},]},
				{"Name" : "VITIS_LOOP_149_3","RefName" : "VITIS_LOOP_149_3","ID" : "32","Type" : "no",
				"SubLoops" : [
				{"Name" : "VITIS_LOOP_150_4","RefName" : "VITIS_LOOP_150_4","ID" : "33","Type" : "no",
					"SubInsts" : [
					{"Name" : "grp_fft1d_fixed_col_Pipeline_VITIS_LOOP_151_5_fu_133", "RefName" : "fft1d_fixed_col_Pipeline_VITIS_LOOP_151_5","ID" : "34","Type" : "sequential",
							"SubLoops" : [
							{"Name" : "VITIS_LOOP_151_5","RefName" : "VITIS_LOOP_151_5","ID" : "35","Type" : "pipeline"},]},]},]},]},
		{"Name" : "grp_fft2d_fixed_top_Pipeline_VITIS_LOOP_211_11_fu_269", "RefName" : "fft2d_fixed_top_Pipeline_VITIS_LOOP_211_11","ID" : "36","Type" : "sequential",
				"SubLoops" : [
				{"Name" : "VITIS_LOOP_211_11","RefName" : "VITIS_LOOP_211_11","ID" : "37","Type" : "pipeline"},]},]},]},]
}]}