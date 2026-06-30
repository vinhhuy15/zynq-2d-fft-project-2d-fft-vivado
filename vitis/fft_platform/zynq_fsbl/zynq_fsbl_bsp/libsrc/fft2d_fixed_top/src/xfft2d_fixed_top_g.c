#include "xfft2d_fixed_top.h"

XFft2d_fixed_top_Config XFft2d_fixed_top_ConfigTable[] __attribute__ ((section (".drvcfg_sec"))) = {

	{
		"xlnx,fft2d-fixed-top-1.0", /* compatible */
		0x40000000 /* reg */
	},
	 {
		 NULL
	}
};