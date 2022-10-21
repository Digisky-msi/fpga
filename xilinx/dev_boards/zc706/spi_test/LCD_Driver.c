/*****************************************************************************
* | File      	:	LCD_Driver.c
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
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "gpio_lcd_test.h"
#include "spidev_lcd_test.h"
#include "LCD_Driver.h"

static int base;
static int channel;
static int spi;

static uint8_t tx[] = {0};  // only do byte write one at a time
static uint8_t rx[] = {0};

/*******************************************************************************
function:
	Hardware reset
*******************************************************************************/
static void LCD_Reset(void)
{
	set_gpio_bit(base, LCD_BL_BIT, 1);
	usleep(200000);
	set_gpio_bit(base, LCD_RST_BIT, 0);
	usleep(200000);
	set_gpio_bit(base, LCD_RST_BIT, 1);
	usleep(200000);
fprintf(stderr, "debug trace LCD reset call gpio ok\n");
}

/*******************************************************************************
function:
		Write data and commands
*******************************************************************************/

static void LCD_Write_Command(UBYTE data)	 
{	
	set_gpio_bit(base, LCD_D1C0_BIT, 0);
////	usleep(10);
  tx[0] = data;
  transfer_byte(spi, tx, rx);
////	usleep(10);
	set_gpio_bit(base, LCD_D1C0_BIT, 1);
}

static void LCD_WriteData_Byte(UBYTE data) 
{	
  tx[0] = data;
  transfer_byte(spi, tx, rx);
}  

void LCD_WriteData_Word(UWORD data)
{
	LCD_WriteData_Byte((data>>8) & 0xff);
	LCD_WriteData_Byte(data & 0xff);
}	  


/******************************************************************************
function:	
		Common register initialization
******************************************************************************/
void LCD_Init(int gl_gpio_base, int nchannel, int fd)
{
  base = gl_gpio_base;
  channel = nchannel;
  spi = fd;
fprintf(stderr, "debug trace LCD receive param ok, base=%d, channel=%d, spi=%d\n", gl_gpio_base, nchannel, fd);
  
	LCD_Reset();

	LCD_Write_Command(0x36);
	LCD_WriteData_Byte(0xA0); 

	LCD_Write_Command(0x3A); 
	LCD_WriteData_Byte(0x05);

	LCD_Write_Command(0x21); 

	LCD_Write_Command(0x2A);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0x01);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0x3F);

	LCD_Write_Command(0x2B);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0xEF);

	LCD_Write_Command(0xB2);
	LCD_WriteData_Byte(0x0C);
	LCD_WriteData_Byte(0x0C);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(0x33);
	LCD_WriteData_Byte(0x33);

	LCD_Write_Command(0xB7);
	LCD_WriteData_Byte(0x35); 

	LCD_Write_Command(0xBB);
	LCD_WriteData_Byte(0x1F);

	LCD_Write_Command(0xC0);
	LCD_WriteData_Byte(0x2C);

	LCD_Write_Command(0xC2);
	LCD_WriteData_Byte(0x01);

	LCD_Write_Command(0xC3);
	LCD_WriteData_Byte(0x12);   

	LCD_Write_Command(0xC4);
	LCD_WriteData_Byte(0x20);

	LCD_Write_Command(0xC6);
	LCD_WriteData_Byte(0x0F); 

	LCD_Write_Command(0xD0);
	LCD_WriteData_Byte(0xA4);
	LCD_WriteData_Byte(0xA1);

	LCD_Write_Command(0xE0);
	LCD_WriteData_Byte(0xD0);
	LCD_WriteData_Byte(0x08);
	LCD_WriteData_Byte(0x11);
	LCD_WriteData_Byte(0x08);
	LCD_WriteData_Byte(0x0C);
	LCD_WriteData_Byte(0x15);
	LCD_WriteData_Byte(0x39);
	LCD_WriteData_Byte(0x33);
	LCD_WriteData_Byte(0x50);
	LCD_WriteData_Byte(0x36);
	LCD_WriteData_Byte(0x13);
	LCD_WriteData_Byte(0x14);
	LCD_WriteData_Byte(0x29);
	LCD_WriteData_Byte(0x2D);

	LCD_Write_Command(0xE1);
	LCD_WriteData_Byte(0xD0);
	LCD_WriteData_Byte(0x08);
	LCD_WriteData_Byte(0x10);
	LCD_WriteData_Byte(0x08);
	LCD_WriteData_Byte(0x06);
	LCD_WriteData_Byte(0x06);
	LCD_WriteData_Byte(0x39);
	LCD_WriteData_Byte(0x44);
	LCD_WriteData_Byte(0x51);
	LCD_WriteData_Byte(0x0B);
	LCD_WriteData_Byte(0x16);
	LCD_WriteData_Byte(0x14);
	LCD_WriteData_Byte(0x2F);
	LCD_WriteData_Byte(0x31);
	LCD_Write_Command(0x21);

	LCD_Write_Command(0x11);

	LCD_Write_Command(0x29);
  
  LCD_Clear(0xFFFF);
}

/******************************************************************************
function:	Set the cursor position
parameter	:
	  Xstart: 	Start UWORD x coordinate
	  Ystart:	Start UWORD y coordinate
	  Xend  :	End UWORD coordinates
	  Yend  :	End UWORD coordinatesen
******************************************************************************/
void LCD_SetWindow(UWORD Xstart, UWORD Ystart, UWORD Xend, UWORD  Yend)
{ 
	LCD_Write_Command(0x2a);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(Xstart & 0xff);
	LCD_WriteData_Byte((Xend - 1) >> 8);
	LCD_WriteData_Byte((Xend - 1) & 0xff);

	LCD_Write_Command(0x2b);
	LCD_WriteData_Byte(0x00);
	LCD_WriteData_Byte(Ystart & 0xff);
	LCD_WriteData_Byte((Yend - 1) >> 8);
	LCD_WriteData_Byte((Yend - 1) & 0xff);

	LCD_Write_Command(0x2C);
}

/******************************************************************************
function:	Settings window
parameter	:
	  Xstart: 	Start UWORD x coordinate
	  Ystart:	Start UWORD y coordinate

******************************************************************************/
void LCD_SetCursor(UWORD X, UWORD Y)
{ 
	LCD_Write_Command(0x2a);
	LCD_WriteData_Byte(X >> 8);
	LCD_WriteData_Byte(X);
	LCD_WriteData_Byte(X >> 8);
	LCD_WriteData_Byte(X);

	LCD_Write_Command(0x2b);
	LCD_WriteData_Byte(Y >> 8);
	LCD_WriteData_Byte(Y);
	LCD_WriteData_Byte(Y >> 8);
	LCD_WriteData_Byte(Y);

	LCD_Write_Command(0x2C);
}

/******************************************************************************
function:	Refresh a certain area to the same color
parameter	:
	  Xstart: Start UWORD x coordinate
	  Ystart:	Start UWORD y coordinate
	  Xend  :	End UWORD coordinates
	  Yend  :	End UWORD coordinates
	  color :	Set the color
******************************************************************************/
void LCD_ClearWindow(UWORD Xstart, UWORD Ystart, UWORD Xend, UWORD Yend,UWORD color)
{          
	UWORD i,j; 
  UWORD size = (Xend-Xstart)*2;
  uint8_t tx[size];
  
	LCD_SetWindow(Xstart, Ystart, Xend, Yend);
  
	for(i = Ystart; i < Yend; i++){													   	 	
		for(j = 0; j < (size/4); j=j+2){
      tx[j] = ((COLOR_RED>>8) & 0xff);
      tx[j+1] = (COLOR_RED & 0xff);
    }
		for(j = (size/4); j < (size/2); j=j+2){
      tx[j] = ((COLOR_GREEN>>8) & 0xff);
      tx[j+1] = (COLOR_GREEN & 0xff);
    }
		for(j = (size/2); j < (size/4+size/2); j=j+2){
      tx[j] = ((COLOR_BLUE>>8) & 0xff);
      tx[j+1] = (COLOR_BLUE & 0xff);
    }
		for(j = (size/4+size/2); j < size; j=j+2){
      tx[j] = ((COLOR_WHITE>>8) & 0xff);
      tx[j+1] = (COLOR_WHITE & 0xff);
    }
    transfer_escaped_string(spi, tx, i);
	}
  
}

/******************************************************************************
function:	Clear screen function, refresh the screen to a certain color
parameter	:
	  Color :		The color you want to clear all the screen
******************************************************************************/
void LCD_Clear(UWORD Color)
{
  LCD_ClearWindow(0, 0, LCD_WIDTH, LCD_HEIGHT, Color);
}

/******************************************************************************
function: Draw a point
parameter	:
	    X	: 	Set the X coordinate
	    Y	:	Set the Y coordinate
	  Color :	Set the color
******************************************************************************/
void LCD_DrawPaint(UWORD x, UWORD y, UWORD Color)
{
	LCD_SetCursor(x, y);
	LCD_WriteData_Word(Color); 	    
}
