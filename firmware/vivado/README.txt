To re-create Vivado projects, execute these tcl scripts here.
Compiled hardware description files (with bitstream included) are stored at "minitel2.0\firmware\hardware_export".


SCREEN

This project only drives the minitel screen. The screen is driven by a 768x574 frame stored in a BRAM shared with PS side.
The PS (A9 processors) can draw on the screen by writing in this shared BRAM.
The shared BRAM is mapped at the physical address 0x4000 0000 (64KB wide).
Each pixel is stored as 1 bit. Thus, each 32-bit word contains 32 pixels.
Each line has 768 pixels, thus a line is stored with 24 consecutive 32-bit words.