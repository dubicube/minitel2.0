# Generates ROM data to store a font in HDL code (cf char_drawer module)
# Data is generated from an refernce picture
# The reference picture is sent to this script by putting its path in the first execution parameter

import sys
from PIL import Image

# Get pixel data for 1 character in the image
def getChar(image, n):
    posX = (n%32)*18
    posY = (n//32)*24
    data = [0]*5
    for x in range(5):
        for y in range(8):
            p = 1-image.getpixel((posX+(x+1)*3+1, posY+y*3+1))
            data[x] = (data[x] & (~(1<<y))) | (p<<y)
    return data

# Test function to print a char in terminal
def printChar(data):
    s = ""
    for y in range(8):
        for x in range(5):
            s+=" " if (data[x]>>y)&1==0 else "*"
        s+="\n"
    print(s)

# Get picture path to read
image_path = ""
if len(sys.argv)>1:
    image_path = sys.argv[1]
else:
    exit()

image = Image.open(image_path)
width, height = image.size

# printChar(getChar(image, 3))

# Extract all characters
result = []
for i in range(256):
    result+=getChar(image, i)

# Format data with VHDL syntax
result = ["x\""+hex(i)[2:].zfill(2)+"\", " for i in result]

# Output data to copy/paste in HDL file
for i in range(len(result)//16):
    print("".join(result[i*16:(i+1)*16]))
