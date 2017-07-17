#include "stdio.h"
#include "ac_int.h"
#include <iostream>


#pragma hls_design top


void vga_mouse_square(bool LEG1, ac_int<10, false> * number_out, ac_int<10, false> * number_in){
	ac_int<10,false> Histogram, HistoOrigin, Histo;
	
	HistoOrigin = *number_in;
	Histogram =  23;
	if(LEG1 == true){
		Histogram = Histogram + 100;
	} 
	Histo = Histogram + HistoOrigin;
	if(Histo > 1023){
		Histo = 23;
	}
	  *number_out = Histo;
}
