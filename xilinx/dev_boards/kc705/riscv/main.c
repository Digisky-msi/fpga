/******************************************************************************
* 
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
* (a) running on a Xilinx device, or (b) that interact
* with a Xilinx device through a bus or interconnect.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
* 
* Modified for RISC-V Soft CPU demo 2022/11/23
* Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
******************************************************************************/



#include <stdio.h>

// for read_cycle
#include "riscv_counters.h"

// for PRIu64
#include <inttypes.h>

// For memory mapped IO
#include "soc_map.h"

int main (int argc, char ** argv)
{
   volatile unsigned char * gpio_addr = (void*)GPIO2_DATA;
   unsigned char pattern = 0;
   unsigned char iter = 0;
   unsigned bitpos = 0;
   unsigned int delay = 0;
   uint64_t start=read_cycle();

   *gpio_addr = 0x10;   // indicate SoT   // RGB-LED glows blue

   // A delay loop
   for (delay = 0; delay < (512*1024); delay++)
      __asm__ __volatile__ ("" ::: "memory");

   printf ("Starting LED sequence ... \n");

   // The LED loop
   for (iter=1; iter < 16; iter++) {
     // increment the gpio val
     (*gpio_addr)++;

     // Print the LED pattern
     printf("LED: ");

     for (bitpos=0; bitpos<4; bitpos++) {
        pattern = (iter >> bitpos) & 0x01;
        if (pattern == 0) printf (" - ");
        else              printf (" X ");
     }
     printf("\n");

     // A delay loop -- the "memory" in the clobber field ensures
     // that gcc optimization flags do not optimize the loop away.
     for (delay = 0; delay < (1024*1024); delay++)
        __asm__ __volatile__ ("" ::: "memory");
   }

   printf ("LED Sequence Complete. \n");
   uint64_t end=read_cycle();
   printf("read_cycle: %" PRIu64 " cycles have elapsed.\n",end-start);
   printf("\n");

   *gpio_addr = 0x20;   // indicate successful EoT // RGB-LED glows green

   while(1){
   };

   return(0);
}
