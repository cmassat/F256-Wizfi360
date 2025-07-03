add1macro .macro address
    lda \address
    clc
    adc #1
    sta \address

    lda \address + 1
    adc #0
    sta \address + 1

.endmacro

sub1macro .macro address
    lda \address
    sec
    sbc #1
    sta \address

    lda \address + 1
    sbc #0
    sta \address + 1
.endmacro

pushReg .macro
    pha
    phx
    phy
.endmacro

A8 .macro
    SEP #$20     ; Set accumulator to 8-bit
    .as          ; Tell assembler we're in 8-bit A mode
.endmacro

A16 .macro
    REP #$20     ; Set accumulator to 16-bit
    .al          ; Tell assembler we're in 16-bit A mode
.endmacro

X8 .macro
    SEP #$10     ; Set index to 8-bit
    .xs          ; Tell assembler we're in 8-bit index mode
.endmacro

X16 .macro
    REP #$10     ; Set index to 16-bit
    .xl          ; Tell assembler we're in 16-bit index mode
.endmacro

AX8 .macro
    SEP #$30     ; Set both A and X to 8-bit
    .as
    .xs
.endmacro

AX16 .macro AX16
    REP #$30     ; Set both A and X to 16-bit
    .al
    .xl
.endmacro


setPointer .macro pointer, address
    lda <#\address
    sta \pointer
    lda >#\address
    sta \pointer + 1
.endmacro

pullReg .macro
    ply
    plx
    pla
.endmacro


; input 
;   no inputs, A register is destructive
; output 
;   A register will have the UART_DATA


delay
    #pushReg
    ldx #0
_outer
    ldy #0
_loop
    iny
    cpy #0
    bne _loop
    inx
    cpx #0
    bne _outer
    #pullReg
    rts

clearScreen
    #a16
    lda #$C000
    sta SCROLL_DEST_PTR
    #AX8
    lda #2
    sta MMU_IO_CTRL
    #AX16

    ldy #0
_loopChar
    lda #$2020
    sta $c000,y
    iny
    iny
    cpy #4800
    
    bcc _loopChar

    #A8 
    stz MMU_IO_CTRL
    #A16
    rts

defaultScreenColor
    #A8
    lda #3
    sta MMU_IO_CTRL
    #A16
    ldy #0
_loopChar
    lda #$5050
    sta $c000,y
    iny
    iny
    cpy #4800
    bne _loopChar
    #A8
    stz MMU_IO_CTRL
    #A16
    rts


clut_default_for
    #A8
    lda #0
    sta MMU_IO_CTRL
    
    ldy #0
_clut_0_default_loop
    lda default_clut_palette,y
    sta CLUT_FOR,y
    iny
    cpy #64
    bne _clut_0_default_loop
    stz MMU_IO_CTRL
    #A16
    rts

clut_default_bck
    #A8
    lda #0
    sta MMU_IO_CTRL
 
    ldy #0
_clut_0_default_loop
    lda default_clut_palette,y
    sta CLUT_BCK,y
    iny
    cpy #64
    bne _clut_0_default_loop
    stz MMU_IO_CTRL
    #A16
    rts

printBuffer
    #pushReg
    ;sta tmpA
    ;stx tmpX
    ;sty tmpY
    #A16
    ldy #0
    lda #2
    sta MMU_IO_CTRL
_loop
    lda tx.txBuffer, y
    sta $C000 + (29 * 80),y
    lda rx.rxBuffer
    sta $C000 + (28 * 80),y
    iny
    iny
    cpy #20
    bne _loop    

    ;lda $D659
    ;sta $C000 + (27 * 80)
    #A8 
    stz MMU_IO_CTRL
    #A8
    #pullReg
    ;lda tmpA
    ;ldx tmpX
    ;ldy tmpY
    rts

saveRegisters
    sta tmpA
    stx tmpX
    sty tmpY
    PHP 
    pla
    sta tmpS

    jsr printA
    jsr printX
    jsr printY
    jsr printS
   ; jsr printtest
    lda tmpA
    ldx tmpX
    ldy tmpY
    plp
    rts 
printA 
    #printReg tmpA, $C000 + (80 * 30)
    rts 
printX 
    #printReg tmpX, $C000 + (80 * 31)
    rts 

printY
    #printReg tmpY, $C000 + (80 * 32)
    rts 

printS
    #printReg tmpS, $C000 + (80 * 33)
    rts

printtest
    #printReg tmpS, $c5d6
    rts
printReg .macro  tempReg, screenPos 
    #A8
    lda #2 
    sta MMU_IO_CTRL
    #A16
    lda \tempReg 
    lsr A
    lsr A
    lsr A 
    lsr A
    lsr A
    lsr A
    lsr A 
    lsr A


    lsr A
    lsr A
    lsr A 
    lsr A
    tax 
    lda m_hex, x
    sta \screenPos


    lda \tempReg  
    lsr A
    lsr A
    lsr A 
    lsr A
    lsr A
    lsr A
    lsr A 
    lsr A
    and #$000F
    tax 
    lda m_hex, x
    sta \screenPos + 1

    lda \tempReg  
    and #$00FF 

    lsr A
    lsr A 
    lsr A 
    lsr A
    tax 
    lda m_hex, x
    sta \screenPos + 2



    lda \tempReg  
    and #$000F 
    tax 
    lda m_hex, x
    sta \screenPos + 3
    #A8 
    stz MMU_IO_CTRL
    #A16
.endmacro 




.section variables
default_clut_palette
    .byte 0, 0, 0 ,0        ; black 0
    .byte 255, 255, 255,0   ; white 1
    .byte 0, 0, 136,0       ; red 2
    .byte 238, 255, 170, 0  ; cyan 3
    .byte $86, $3d, $6F,0    ; purple 4
    .byte 85, 204, 0,0      ; green 5
    .byte 170,0,0,0         ; blue 6
    .byte 119, 238,238,0    ; yellow 7
    .byte 85,136, 221,0     ; orange 8
    .byte 0, 68, 192,0      ; brown 9
    .byte 119, 119, 255,0   ; light red a
    .byte 51, 51, 51,0      ; dark grey b
    .byte 119, 119, 119,0   ; grey c  bright black
    .byte 102, 255, 119, 0  ; light green d
    .byte 255, 136,0,0      ; light blue e
    .byte 187, 187, 187,0   ; light grey f
    .byte 0, 0, 0 ,0        ; black 0
default_clut_palette_end


m_hex
    .text '0123456789ABCDEF'


tmp 
    .word $00
tmpA 
    .word $00
tmpX
    .word $00
tmpY 
    .word $00
tmpS
    .word $00
.endsection