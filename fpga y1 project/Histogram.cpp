#include <ac_fixed.h>
#include <iostream>

// shift_class: page 119 HLS Blue Book
#include "shift_class.h" 




#pragma hls_design top
void mean_histo(ac_int<PIXEL_WL*KERNEL_WIDTH,false> vin[NUM_PIXELS], ac_int<PIXEL_WL,false> vout[NUM_PIXELS])
{
    ac_int<16, false> red, green, blue, r[KERNEL_WIDTH], g[KERNEL_WIDTH], b[KERNEL_WIDTH];
    

// #if 1: use filter
// #if 0: copy input to output bypassing filter
#if 1

    // shifts pixels from KERNEL_WIDTH rows and keeps KERNEL_WIDTH columns (KERNEL_WIDTHxKERNEL_WIDTH pixels stored)
    static shift_class<ac_int<PIXEL_WL*KERNEL_WIDTH,false>, KERNEL_WIDTH> regs;
    int i;

    FRAME: for(int p = 0; p < NUM_PIXELS; p++) {
		// init
		red = 0; 
		green = 0; 
		blue = 0;
		RESET: for(i = 0; i < KERNEL_WIDTH; i++) {
			r[i] = 0;
			g[i] = 0;
			b[i] = 0;
		}
	    
		// shift input data in the filter fifo
		regs << vin[p]; // advance the pointer address by the pixel number (testbench/simulation only)
		// accumulate
		ACC1: for(i = 0; i < KERNEL_WIDTH; i++) {
			// current line
			r[0] += (regs[i].slc<COLOUR_WL>(2*COLOUR_WL));
			g[0] += (regs[i].slc<COLOUR_WL>(COLOUR_WL));
			b[0] += (regs[i].slc<COLOUR_WL>(0));
			// the line before ...
			r[1] += (regs[i].slc<COLOUR_WL>(2*COLOUR_WL + PIXEL_WL));
			g[1] += (regs[i].slc<COLOUR_WL>(COLOUR_WL + PIXEL_WL));
			b[1] += (regs[i].slc<COLOUR_WL>(0 + PIXEL_WL));
			// the line before ...
			r[2] += (regs[i].slc<COLOUR_WL>(2*COLOUR_WL + 2*PIXEL_WL));
			g[2] += (regs[i].slc<COLOUR_WL>(COLOUR_WL + 2*PIXEL_WL)) ;
			b[2] += (regs[i].slc<COLOUR_WL>(0 + 2*PIXEL_WL)) ;
			// the line before ... 
			r[3] += (regs[i].slc<COLOUR_WL>(2*COLOUR_WL + 3*PIXEL_WL));
			g[3] += (regs[i].slc<COLOUR_WL>(COLOUR_WL + 3*PIXEL_WL)) ;
			b[3] += (regs[i].slc<COLOUR_WL>(0 + 3*PIXEL_WL)) ;
			// the line before ...
			r[4] += (regs[i].slc<COLOUR_WL>(2*COLOUR_WL + 4*PIXEL_WL));
			g[4] += (regs[i].slc<COLOUR_WL>(COLOUR_WL + 4*PIXEL_WL)) ;
			b[4] += (regs[i].slc<COLOUR_WL>(0 + 4*PIXEL_WL)) ;
		}
		// add the accumualted value for all processed lines
		ACC2: for(i = 0; i < KERNEL_WIDTH; i++) {    
			red += r[i];
			green += g[i];
			blue += b[i];
		}
		// normalize result
		red /= KERNEL_NUMEL;
		green /= KERNEL_NUMEL;
		blue /= KERNEL_NUMEL;

		// black and white the image
		ac_int<16,false> intensity=(red+green+blue)/3;
		 red = intensity;
		 green = intensity;
		 blue  = intensity;
		 
		//
	    
		// group the RGB components into a single signal
		vout[p] = ((((ac_int<PIXEL_WL, false>)red) << (2*COLOUR_WL)) | (((ac_int<PIXEL_WL, false>)green) << COLOUR_WL) | (ac_int<PIXEL_WL, false>)blue);
	    
    }
}