////////////////////////////////////////////////////////////////////////////////
//  _____                           _       _    _____      _ _
// |_   _|                         (_)     | |  / ____|    | | |
//   | |  _ __ ___  _ __   ___ _ __ _  __ _| | | |     ___ | | | ___  __ _  ___
//   | | | '_ ` _ \| '_ \ / _ \ '__| |/ _` | | | |    / _ \| | |/ _ \/ _` |/ _ \
//  _| |_| | | | | | |_) |  __/ |  | | (_| | | | |___| (_) | | |  __/ (_| |  __/
// |_____|_| |_| |_| .__/ \___|_|  |_|\__,_|_|  \_____\___/|_|_|\___|\__, |\___|
//                 | |                                                __/ |
//                 |_|                                               |___/
//  _                     _
// | |                   | |
// | |     ___  _ __   __| | ___  _ __
// | |    / _ \| '_ \ / _` |/ _ \| '_ \
// | |___| (_) | | | | (_| | (_) | | | |
// |______\___/|_| |_|\__,_|\___/|_| |_|
//
////////////////////////////////////////////////////////////////////////////////
//  File:           vga_mouse_square.cpp
//  Description:    video to vga with mouse pointer - real-time processing
//  By:             rad09
////////////////////////////////////////////////////////////////////////////////
// this hardware block receives the VGA scanning coordinates, 
// the mouse coordinates and then replaces the mouse pointer 
// with a different value for the pixel
////////////////////////////////////////////////////////////////////////////////
// Catapult Project options
// Constraint Editor:
//  Frequency: 27 MHz
//  Top design: vga_mouse_square
//  clk>reset sync: disable; reset async: enable; enable: enable
// Architecture Constraint:
//  core>main: enable pipeline + loop can be merged
////////////////////////////////////////////////////////////////////////////////



#include "stdio.h"
#include "ac_int.h"

#define COLOR_WL          10
#define PIXEL_WL          (3*COLOR_WL)

#define  COORD_WL          10

#pragma hls_design top
void vga_mouse_square(ac_int<(COORD_WL+COORD_WL), false> * vga_xy, ac_int<(COORD_WL+COORD_WL), false> * mouse_xy, ac_int<(8), false> cursor_size, 
    ac_int<PIXEL_WL, false> * video_in, ac_int<PIXEL_WL, false> * video_out)
{
    ac_int<10, false> i_red, i_green, i_blue; // current pixel
    ac_int<10, false> o_red, o_green, o_blue; // output pixel
	ac_int<10, false> average;

    
/*  --extract the 3 color components from the 30 bit signal--
    the 2 blocks are identical - you can shift and mask the desired bits or "slice" the signal <length>(location)
    
    i_red = *video_in >> 20;
    i_green = (*video_in >> 10) & (ac_int<10>)1023;
    i_blue = *video_in & ((ac_int<10>)1023); 
*/    
    i_red = (*video_in).slc<COLOR_WL>(20);
    i_green = (*video_in).slc<COLOR_WL>(10);
    i_blue = (*video_in).slc<COLOR_WL>(0);
	
	average=(i_red + i_green + i_blue)/3;

	if(i_red >= 100){
		o_red = i_red * (1023/average);
		o_green = i_green;
		o_blue = i_blue;
	}else{
		o_red = i_red;
		o_green = i_green;
		o_blue = i_blue;
	}
	

   
    
    *video_out = ((((ac_int<PIXEL_WL, false>)o_red) << 20) | (((ac_int<PIXEL_WL, false>)o_green) << 10) | (ac_int<PIXEL_WL, false>)o_blue);
}