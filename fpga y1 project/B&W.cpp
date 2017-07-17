#include "stdio.h"
#include "ac_int.h"

#define COLOR_WL          10
#define PIXEL_WL          (3*COLOR_WL)

#define  COORD_WL          10

#pragma hls_design top
void vga_black_white(ac_int<(COORD_WL+COORD_WL), false> * vga_xy, ac_int<(COORD_WL+COORD_WL), false> * mouse_xy, ac_int<(8), false> cursor_size, 
    ac_int<PIXEL_WL, false> * video_in, ac_int<PIXEL_WL, false> * video_out)
{
    ac_int<10, false> i_red, i_green, i_blue; // current pixel
    ac_int<10, false> o_red, o_green, o_blue; // output pixel
    

    
/*  --extract the 3 color components from the 30 bit signal--
    the 2 blocks are identical - you can shift and mask the desired bits or "slice" the signal <length>(location)
    
    i_red = *video_in >> 20;
    i_green = (*video_in >> 10) & (ac_int<10>)1023;
    i_blue = *video_in & ((ac_int<10>)1023); 
*/    
    i_red = (*video_in).slc<COLOR_WL>(20);
    i_green = (*video_in).slc<COLOR_WL>(10);
    i_blue = (*video_in).slc<COLOR_WL>(0);

 
    // extract VGA pixel X-Y coordinates
    vga_x = (*vga_xy).slc<COORD_WL>(0);
    vga_y = (*vga_xy).slc<COORD_WL>(10);
   
   
    
    /// something here...
    i_grey = (i_red + i_green + i_blue) /3
    
    /// show pixel

        // if it is outside the mouse square
        o_red = i_grey;
        o_green = i_grey;
        o_blue = i_grey;
    }
    
    // combine the 3 color components into 1 signal only
    *video_out = ((((ac_int<PIXEL_WL, false>)o_red) << 20) | (((ac_int<PIXEL_WL, false>)o_green) << 10) | (ac_int<PIXEL_WL, false>)o_blue);