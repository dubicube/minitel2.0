/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "xil_io.h"
#include "sleep.h"

#define SCREEN_WIDTH 768
#define SCREEN_HEIGHT 574

void drawPixel(int x, int y, int value) {
   u32 v = Xil_In32(0x40000000 + (y*24+(x>>5))*4);
   v = v&(~(1<<(x&0x1F)));
   v = v | ((value&1)<<(x&0x1F));
   Xil_Out32(0x40000000 + (y*24+(x>>5))*4, v);
}

void drawRect(int x0, int y0, int x1, int y1, int value) {
   for (int y = y0; y < y1; y++) {
      for (int x = x0; x < x1; x++) {
         drawPixel(x, y, value);
      }
   }
}

u64 getKeyBoard() {
   u64 v = Xil_In32(0x41000000);
   v |= ((u64)Xil_In32(0x41000004))<<32;
   return v;
}



// This example allows to move a rectangle on the screen using the arrow keys

int main() {
   init_platform();

   print("Hello World\n\r");

   int x = 100;
   int y = 100;
   int width = 20;
   int height = 10;

   while (1) {
      drawRect(x, y, x+width, y+height, 0);
      u64 k = getKeyBoard();
      if (!(k&0x0000000000000001)) {//Up arrow
         y--;
      }
      if (!(k&0x0000000000000008)) {//Down arrow
         y++;
      }
      if (!(k&0x0000000000000020)) {//Left arrow
         x--;
      }
      if (!(k&0x0000000000000040)) {//Right arrow
         x++;
      }
      drawRect(x, y, x+width, y+height, 1);
      usleep(10000);
   }

   cleanup_platform();
   return 0;
}
