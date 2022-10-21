/*
*
* gpio_lcd_test header
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
* IN NO EVENT SHALL XILINX AND/OR DIGISKY BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in this
* Software without prior written authorization from Xilinx.
*
*
* Modified for SPI LCD demo test 2022/10/19
*/
#ifndef _GPIO_LCD_TEST_H_
#define _GPIO_LCD_TEST_H_

#define LCD_RST_H 0x01
#define LCD_RST_L 0x00
#define LCD_CS_H  0x02
#define LCD_CS_L  0x00
#define LCD_D1    0x04
#define LCD_C0    0x00
#define LCD_BL_H  0x08
#define LCD_BL_L  0x00
#define LCD_RST_BIT   0x00
#define LCD_CS_BIT    0x01
#define LCD_D1C0_BIT  0x02
#define LCD_BL_BIT    0x03

void usage (char *argv0);
int open_gpio_channel(int gpio_base);
int close_gpio_channel(int gpio_base);
int set_gpio_direction(int gpio_base, int nchannel, char *direction);
int set_gpio_value(int gpio_base, int nchannel, int value);
int set_gpio_bit(int gpio_base, int channel, int value);
int get_gpio_value(int gpio_base, int nchannel);
void signal_handler(int sig);

int main(int argc, char *argv[]);

#endif
