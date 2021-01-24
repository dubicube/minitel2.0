# Video modules
## Architecture
![alt text](https://github.com/dubicube/minitel2.0/blob/main/doc/pics/video.png?raw=true)

## PAL
The module PAL generates a synchronization signal respecting the PAL standard, just out of a 60MHz clock. Internally, it works with some X/Y counters to sweep the screen, to generate the sync signal according to the current position of the counters. Counter values are also output fore uses in other modules.

The sync signal generates a 625 line interlaced frame at 25 fps (25 frames per second and 50 fields per second). Thus, each line is 64us long.

## Active video generator
This module detects the horizontal and vertical blankings.

It takes outputs from PAL module to generate coordinates in the active video region. The signal OE_Video indicates when the video is active or not. The output signals POSX and POSY are the position of the current video relative in the active video region. Thus, this position is not valid when the video is no active (when OE_Video equals '0').

## Buffer2pal
This module generates video data from a position in the frame, and a BRAM access (used as frame buffer).

This architecture is intended to be used with a dual port BRAM shared between the module Buffer2pal that reads the buffer, and another entity (typically a processor) that writes video in the buffer. This module reads the buffer according to the input position, and generates a corresponding video signal, synchronous to the synchronization signal.

## BRAM2video
This module is just a top module including the different video modules.
