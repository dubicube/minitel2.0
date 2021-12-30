To re-create Vivado projects, execute these tcl scripts here.
Compiled hardware description files (with bitstream included)
are stored at "minitel2.0\firmware\hardware_export".


SCREEN_KEYBOARD

This project drives the minitel screen and gets keyboard inputs.

The screen is driven by a 768x512 frame stored in a BRAM shared with PS side.
The PS (A9 processors) can draw on the screen by writing in this shared BRAM.
The shared BRAM is mapped at the physical address 0x4000 0000 (64KB wide).
Each pixel is stored as 1 bit. Thus, each 32-bit word contains 32 pixels.
Pixels are aligned in columns, thus the 16 first 32-bit-words are for column 0,
and then starts column 1, and so on.

An accelerator allows to quickly draw char from PS.
This peripheral is mappad at physical address 0x4001 0000.
Writing bytes at this address allows to control the screen just like a terminal.
Some ANSI escape sequences are supported, to move the cursor for example.

The keyboard data can be retreived at physical address 0x4002 0000.
The two 32-bits-registers at offset +0x00 and +0x04 represents a 64-bits-word
where each bit correspond to a key on the keyboard.
In this 64-bits-word, logic is inverted, thus a '0' indicates
the key is pressed.
Keyboard inputs can also be listenned by reading the register at offset +0x08.
In this register, firmware outputs regular ASCII code.
Check the corresponding module for more information.
An interrupt is generated when a new char is available from the keyboard
controller.
