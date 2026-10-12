.define TI86

.ifdef TI82
 #include "ti82_t6c79.inc"
 .echoln "This has NOT been tested! Use CrASH 19.006"
 .echoln "Code expects a T6C79 so only 19.006 is targeted."
 .binarymode TI82
 .define USES_SHELL
 .define BPORT_LINK_B2_B3
 ; bport controls ROM page, but that address pin isn't hooked up
 .define BPORT_PAGED
 .define bcall(xxxx) call xxxx
 .define asm_ram OP5
 .org asm_exec_ram-3
 .db tReturn,$00,$11
 .db "LinkView ROM 19.006",0
.elseifdef TI83
 #include "ti83.inc"
 .binarymode TI83
 .define BPORT_LINK_B2_B3
 .define BPORT_PAGED
 .define bcall(xxxx) call xxxx
 .org userMem
 .unsquish
.elseifdef TI8X
 #include "ti83plus.inc"
 .binarymode TI8X
 .org userMem-2
 .db t2ByteTok,tAsmCmp
.elseifdef TI85
 #include "ti85_10.0_temp.inc"
 .binarymode TI85
 .define bcall(xxxx) call xxxx
 .define asm_ram OP6
 .org asm_exec_ram ; ZShell header??
 .db "LinkView ROM 10.0",0
.elseifdef TI86
 #include "ti86.inc"
 .binarymode TI86
 .define bcall(xxxx) call xxxx
 .define asm_ram OP6
 .org asm_exec_ram-2
 .db $8E,$28 ;t2ByteTok tAsmCmp
.endif

.define LocalLinkFlags asm_flag1
.define LinkFail 0
.define HandleIdle 1
.define LinkCounter $FFFF
.define IdleCounter_init $80

.varloc asm_ram, 20
.var 4,	ErrHandPush
.var 1,	RecByte
.var 3,	RecByteStr
.var 2, IdleCounter

Setup:
 ;bcall(_NewLine)
 .ifndef USES_SHELL
  bcall(_RunIndicOff)
 .else
  ; launching from a shell leaves a dirty screen
  bcall(_ClrScrnFull)
 .endif
 res HandleIdle,(iy+LocalLinkFlags)
 ld hl,IdleCounter_init
 ld (IdleCounter),hl
Main:
 ei
 halt
 bcall(_GetCSC)
 or a
 jr nz,Main_Exit
 bit HandleIdle,(iy+LocalLinkFlags)
 jr z,Main_SkipIdle
 ld hl,(IdleCounter)
 dec hl
 ld (IdleCounter),hl
 ld a,h
 or l
 call z,Main_NewIdle
Main_SkipIdle:
 in a,(bport)
 and D0D1_bits
 cp D0D1_bits
 jr z,Main
 di
 set HandleIdle,(iy+LocalLinkFlags)
 ld hl,IdleCounter
 ld (hl),IdleCounter_init
 ld hl,ioData
 ld (hl),a
 ld b,15
Main_DebounceLoop:
 in a,(bport)
 and D0D1_bits
 cp (hl)
 jr nz,Main
 djnz Main_DebounceLoop
SkipDebounce:
 call TryToReceiveByte
 ld a,(RecByte)
 ld de,RecByteStr
 bit LinkFail,(iy+LocalLinkFlags)
 jr nz,Main_LinkFailed
 push de
  call A2MDE_Hex
  xor a
  ld (de),a
 pop hl
Main_PrintAndRestart:
 ei
 bcall(_PutS)
 jp Main

Main_Exit:
 bit HandleIdle,(iy+LocalLinkFlags)
 jr z,{+}
 bcall(_NewLine)
 +:
 in a,(bport)
 and $F0
 out (bport),a
 ret

Main_NewIdle:
 bcall(_NewLine)
 res HandleIdle,(iy+LocalLinkFlags)
 ld hl,IdleCounter_init
 ld (IdleCounter),hl
 ret

Main_LinkFailed:
 ; Display two exclamation marks if transfer failed
 ; Inputs: de points to string memory
 ; Outputs: Jumps to _PutS with string memory in hl
 ; Destroys: all except bc
 ld a,lExclam
 push de
  ld (de),a
  inc de
  ld (de),a
  inc de
  xor a
  ld (de),a
 pop hl
 jp Main_PrintAndRestart

TryToReceiveByte:
 ; make this a subroutine so the stack ends up one higher than Main
 ; Inputs: None
 ; Outputs: LinkFail flag set if transfer failed. 
 ;          Transferred byte in (RecByte)
 ; Destroys: All
 ;ld hl,LocalLinkErrorHandler
 ;call InstallErrorHandler
 ; res LinkFail,(iy+LocalLinkFlags)
 ; ld a,_IO_RecAByteIO
 ; ld (asm_ind_call),a
 ; ;bcall(IO_Exec)
  call RawReadByte
  ld (RecByte),a
 ;call RemoveErrorHandler
 ret

A2MDE_Hex:
; Writes A as ASCII hex bytes to (DE)
; Inputs: A, DE
; Outputs: DE+2 (location of next write for serial calls)
; Destroys: AF
; stolen from srec_dump_app
 push bc
 ; i gave up and found some code on the internet
  ld c,a
  rra
  rra
  rra
  rra
  call {+}
  ld a,c
  ; handle high bits
  call {+} 
 pop bc
 ret
+:
 and $0F
 add a,$90
 daa
 adc a,$40
 daa
 ld (de),a
 inc de
 ret

;InstallErrorHandler:
; ; create a temporary jump
; push hl ; argument for _PushErrHandler
; push de ; preserve this register  
; ld hl,_PushErrorHandler+1 ; find the entrypoint for our entrypoint, skipping CD byte
; bcall(_ldHLind) ; read the page 0 address within this entrypoint
; ld de,ErrHandPush ; load where we want to create this entrypoint
; ex de,hl ; we can write any register to (hl) but only a to (de)
; ld a,$C3 ; opcode for jp
; ld (hl),a ; write this first. 16-bit address to follow
; inc hl
; ld (hl),e ; low byte for page 0 entrypoint
; inc hl
; ld (hl),d ; high byte for page 0 entrypoint
; pop de ; register preserved
; pop hl ; the next value on the stack is the address after we called InstallErrorHandler
; jp ErrHandPush ; transfer control to this entrypoint we synthesized
; 
;RemoveErrorHandler:
; pop de ; preserve our calling address
; ld hl,_PopErrorHandler+1 ; skip the CD byte
; bcall(_ldHLind) ; hl = (hl)
; push de ; put it back on the stack
; jp (hl) ; transfer control to the address we yanked out of page $0C
;
;LocalLinkErrorHandler:
; set LinkFail,(iy+LocalLinkFlags)
; push af
; .ifdef BPORT_PAGED
; in a,(bport)
; and $F0
; .else
; ld a,D0HD1H
; .endif
; out (bport),a
; pop af
; ret ; must be in a link subroutine or we'll exit Main

RawReadByte:
 di
 ld b,8
 ld c,0
 ld de,LinkCounter
 RRBy_init:
  dec de
  ld a,d
  or e
  jp z,RRBy_LinkFail
  in a,(bport)
  .ifdef BPORT_LINK_B2_B3
   rra
   rra
  .endif
  and %00000011
  cp %00000011
  jr z,RRBy_init
  or a
  jr z,RRBy_LinkFail
  ccf
  rrc c ; sent LSb first
  cp %00000010
  jr z,RRBy_D0LD1H ; logical 0
  ; logical 1
  set 7,c
  call SetD0LD1H ; new link state D0LD1L, other side to release
  RRBy_NoBit:
  ; complete the handshake
  nop
  nop
  nop
  nop ; let the hardware catch up
  ; wait for other side to release the link lines
  ; state to change from ex. D0LD1L to D0HD1L
  ld de,LinkCounter
 -:
  in a,(bport)
  and D0D1_bits
  jr nz,{+}
  dec de
  ld a,d
  or e
  jr z,RRBy_LinkFail
  jr {-}
 +:
  .ifdef BPORT_PAGED
   in a,(bport)
   and $F0
   ;or D0HD1H
  .else
   ld a,D0HD1H
  .endif
  out (bport),a
  ld de,LinkCounter
 -:
  in a,(bport)
  and D0D1_bits
  cp D0D1_bits
  jr z,{+}
  dec de
  ld a,d
  or e
  jr z,RRBy_LinkFail
  jr {-}
 +:
  djnz RRBy_init
  ld a,c
  ei
  ret
 
RRBy_LinkFail:
 xor a
 set LinkFail,(iy+LocalLinkFlags)
 ei
 ret
 
RRBy_D0LD1H:
 call SetD0HD1L
 jp RRBy_NoBit

SetD0LD1H:
 push af
  .ifdef BPORT_PAGED
  in a,(bport)
  and $F0
  or D0LD1H
 .else
  ld a,D0LD1H
 .endif
-:
 out (bport),a
 pop af
 ret

SetD0HD1L:
 push af
  .ifdef BPORT_PAGED
  in a,(bport)
  and $F0
  or D0HD1L
 .else
  ld a,D0HD1L
 .endif
 jr {-}

SetD0HD1H:
 push af
  .ifdef BPORT_PAGED
  in a,(bport)
  and $F0
  or D0HD1H
 .else
  ld a,D0HD1H
 .endif
 jr {-}

.ifdef TI83
 .squish
 .db tEnd,tEnter,t0,t0,t0,t0,tEnter,tEnd
.endif