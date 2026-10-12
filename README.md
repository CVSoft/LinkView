# LinkView
View bytes traversing the TI-83 link port

## Building
Set the define for the platform you want to assemble for, then assemble with Brass. This program requires modified include files. Since the development of these include files is in active development with known errors present, they are not being released at this time. 

## Installation
LinkView currently targets the TI-82 and TI-83. TI-83 Plus support is planned but not yet functional. Transfer the .82p or .83p file to your calculator. For TI-82, open CrASH and run the program from the CrASH shell. For TI-83, launch using the standard `Send(9prgmLINKVIEW` nostub assembly launching method. 

## Usage
When the program is running, nothing will appear until link port activity occurs. When activity occurs, the bytes appear as hexadecimal on the screen. In the event of a link protocol failure (such as a too-long link cable or poor contact), those bytes appear as !!. There isn't much of an attempt to recover from that state, so restart the program if you get a string of them or the output switches to nonsense. 

Press any key to exit the program. 

## Why No TI-83 Plus?
The TI-83 Plus ASIC works a little differently. I haven't worked out exactly how different it is. Since I care more about getting the code out right now than actually fixing it, it is currently broken. You can experience this yourself by building and running the code against Brass and BrandonW's Ultimate TI-83 Plus Include File. 

## Notes
I wrote this program as a one-off exercise to quickly slap something together to view requests being sent by WebTILP to a TI-83. It didn't end up being quick due to a combination of `_RecAByteIO` not doing what I want, error handler insertion being strange on TI-83, and documentation targeting the TI-83 Plus not aligning with the TI-83. The TI-82 Parcus and TI-83 are very similar devices, so adding TI-82 support took only a few minutes. I had written all of the code, raw link port access and all, before I even considered supporting the TI-83 Plus, so I tried to shoehorn in TI-83 Plus support without success. I'll fix it later when I have time -- it already works on my TI-83 development platform, so it's not an immediate interest. 
