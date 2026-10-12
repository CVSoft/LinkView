# LinkView
View bytes traversing the TI-83 link port

## Building
Set the define for the platform you want to assemble for, then assemble with Brass. This program requires modified include files. Since the development of these include files is in active development with known errors present, they are not being released at this time. 

## Installation
LinkView currently targets the TI-82, TI-83, and TI-83 Plus. Transfer the .82p, .83p, or .8xp file to your respective TI-82, TI-83, or TI-83 Plus. For TI-82, open CrASH and run the program from the CrASH shell. For TI-83, launch using the standard `Send(9prgmLINKVIEW` nostub assembly launching method. For TI-83 Plus, launch using the standard `Asm(prgmLINKVIEW` nostub assembly launching method; I do not recommend launching this from a shell, although it probably would work fine.

TI-83 Plus Silver Edition, TI-84 Plus, and TI-84 Plus Silver Edition (as well as the TI-Nspire emulation) should work as well, since I'm not abusing the hardware at all. Treat all of these as a TI-83 Plus. Color calculators (namely the TI-84 Plus C Silver Edition) are not supported at this time. If your TI-84 Plus doesn't have an I/O port next to the Mini-USB port, this program won't be particularly useful to you. 

## Usage
When the program is running, nothing will appear until link port activity occurs. When activity occurs, the bytes appear as hexadecimal on the screen. In the event of a link protocol failure (such as a too-long link cable or poor contact), those bytes appear as !!. There isn't much of an attempt to recover from that state, so restart the program if you get a string of them or the output switches to nonsense. 

Press any key to exit the program. 

## Notes
I wrote this program as a one-off exercise to quickly slap something together to view requests being sent by WebTILP to a TI-83. It didn't end up being quick due to a combination of `_RecAByteIO` not doing what I want, error handler insertion being strange on TI-83, and documentation targeting the TI-83 Plus not aligning with the TI-83. The TI-82 Parcus and TI-83 are very similar devices, so adding TI-82 support took only a few minutes. I had written all of the code, raw link port access and all, before I even considered supporting the TI-83 Plus, so I tried to shoehorn in TI-83 Plus support without success. After re-evaluating my life choices, I rolled code back to an earlier version, and applied what I had learned between then and now to get working TI-83 Plus binaries. 
