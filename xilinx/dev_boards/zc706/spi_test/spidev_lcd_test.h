/*
*
* spidev_lcd_test header
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
#ifndef _SPIDEV_LCD_TEST_H_
#define _SPIDEV_LCD_TEST_H_
#include <stdint.h>


void pabort(const char *s);
void hex_dump(const void *src, size_t length, size_t line_size, char *prefix);
int unescape(char *_dst, char *_src, size_t len);
void transfer(int fd, uint8_t const *tx, uint8_t const *rx, size_t len);
void transfer_byte(int fd, uint8_t const *tx, uint8_t const *rx);
void print_usage(const char *prog);
void parse_opts(int argc, char *argv[]);
void transfer_escaped_string(int fd, char *str, int i);
void transfer_file(int fd, char *filename);
void show_transfer_rate(void);
void transfer_buf(int fd, int len);

int spidev_main(int gl_gpio_base, int nchannel);



#endif
