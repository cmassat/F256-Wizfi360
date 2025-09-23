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

clearScreen
    lda <#$C000
    sta SCROLL_DEST_PTR
    lda >#$C000
    sta SCROLL_DEST_PTR + 1
    lda #2
    sta MMU_IO_CTRL

    ldx #0 
_loopRow 
    ldy #0
_loopChar
    lda #$20
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny 
    cpy #80 
    bcc _loopChar
    inx 
    cpx #30 
    bcc _loopRow
         
    stz MMU_IO_CTRL

    rts



isTimerComplete
    lda mTimer
    cmp #$05
    bcc _nope   
    clc
    stz mTimer
    rts 
_nope 
    sec 
    rts 

setDebounce
    stz mTimer
    rts 

isKeyscanReady
    lda mTimer 
    cmp #2   ;20 milisonds 
    bcs _yes
    sec  
    rts 
_yes 
    stz mTimer
    clc 
    rts 

defaultScreenColor
    #pushReg
    lda <#$C000
    sta SCROLL_DEST_PTR
    lda >#$C000
    sta SCROLL_DEST_PTR + 1
    lda #3
    sta MMU_IO_CTRL

    ldx #0 
_loopRow 
    ldy #0
_loopChar
    lda #$50
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny 
    cpy #80 
    bcc _loopChar
    inx 
    cpx #60
    bcc _loopRow
         
    stz MMU_IO_CTRL
    #pullReg
    rts


clut_default_for
    
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
    
    rts

clut_default_bck
    
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
    
    rts

printBuffer
    #pushReg

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
     
    stz MMU_IO_CTRL
    
    #pullReg

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
    
    lda #2 
    sta MMU_IO_CTRL
    
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
     
    stz MMU_IO_CTRL
    
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