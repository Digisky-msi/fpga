/*****************************************************************************
* | File      	:	LCD_Driver.h
* | Author      :   Waveshare team
* | Function    :   LCD driver
* | Info        :
*----------------
* |	This version:   V1.0
* | Date        :   2018-12-18
* | Info        :   
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documnetation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to  whom the Software is
# furished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS OR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
*
* Modified for SPI LCD demo test 2022/10/19
* Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
******************************************************************************/
#ifndef __LCD_DRIVER_H
#define __LCD_DRIVER_H
#include <stdint.h>

#define UBYTE   uint8_t
#define UWORD   uint16_t
#define UDOUBLE uint32_t


#define LCD_WIDTH   320 //LCD width
#define LCD_HEIGHT  240 //LCD height

#define COLOR_RED     0xF842  //can't use byte 00 as will stop the string transfer, set black level to 2 anyway
#define COLOR_GREEN   0x17E2
#define COLOR_BLUE    0x025F
#define COLOR_WHITE   0xF7FF
#define COLOR_BLACK   0x1042

 
void LCD_WriteData_Word(UWORD da);

void LCD_SetCursor(UWORD X, UWORD Y);
void LCD_SetWindow(UWORD Xstart, UWORD Ystart, UWORD Xend, UWORD  Yend);
void LCD_DrawPaint(UWORD x, UWORD y, UWORD Color);

void LCD_Init(int gl_gpio_base, int nchannel, int fd);
void LCD_SetBackLight(UWORD Value);

void LCD_Clear(UWORD Color);
void LCD_ClearWindow(UWORD Xstart, UWORD Ystart, UWORD Xend, UWORD Yend,UWORD color);

#endif
