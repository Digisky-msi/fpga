/*
* "Hello World" example.
*
* This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
* the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
* designs. 
*
* Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Intel device, or (b) that interact
* with a Intel device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
* Modified for MAX10 NIOS demo test 2023/04/27
*/


#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

int main()
{
  int SW_ver = 4;
  
  int i = 0;
  alt_printf("MAX10 Nios II demo print!\n");

  int in, out;
  int freq = 0;
  
  while(1){
    alt_printf("Count 0x%x ,",i);
    
    in = IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE);
    freq = (in & 0xFFFFF); // 20-bit
    
    out = SW_ver & 0x000000FF;
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE,out);
    
    alt_printf("ADC clock frequency = %x KHz\n\n",freq);
    usleep(1000000); //1S
    
    i = i+1;
  
  }

  return 0;
}
