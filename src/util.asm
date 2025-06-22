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


; input 
;   no inputs, A register is destructive
; output 
;   A register will have the UART_DATA
read_uart_data
    lda UART_CTRL
    and #CTRL_RX_EMPTY        ; mask for the RX empty bit
    cmp #CTRL_RX_EMPTY        ; loop while buffer is empty
    beq _doneRead

    lda UART_DATA
    clc 
    rts
_doneRead
    sec 
    rts

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
    lda #<$c000
    sta SCROLL_DEST_PTR
    lda #>$c000
    sta SCROLL_DEST_PTR + 1
    lda #2
    sta MMU_IO_CTRL

    ldx #0
_loopLine
    ldy #0
_loopChar
    lda #$20
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny
    cpy #80
    bne _loopChar
    inx
    cpx #60
    bne _loopLine
    stz MMU_IO_CTRL
    rts

defaultScreenColor
    lda #<$c000
    sta SCROLL_DEST_PTR
    lda #>$c000
    sta SCROLL_DEST_PTR + 1
    lda #3
    sta MMU_IO_CTRL

    ldx #0
_loopLine
    ldy #0
_loopChar
    lda #$50
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny
    cpy #80
    bne _loopChar
    inx
    cpx #60
    bne _loopLine
    stz MMU_IO_CTRL
    rts


clut_default_for
    lda #0
    sta MMU_IO_CTRL

    lda #<default_clut_palette
    sta POINTER_CLUT_SRC

    lda #>default_clut_palette
    sta POINTER_CLUT_SRC+1

    lda #<CLUT_FOR
    sta POINTER_CLUT_DEST
    lda #>CLUT_FOR
    sta POINTER_CLUT_DEST+1

    ldy #0
_clut_0_default_loop
    lda (POINTER_CLUT_SRC),y
    sta (POINTER_CLUT_DEST),y
    iny
    cpy #68
    bne _clut_0_default_loop
    stz MMU_IO_CTRL
    rts

clut_default_bck
    lda #0
    sta MMU_IO_CTRL

    lda #<default_clut_palette
    sta POINTER_CLUT_SRC

    lda #>default_clut_palette
    sta POINTER_CLUT_SRC+1

    lda #<CLUT_BCK
    sta POINTER_CLUT_DEST
    lda #>CLUT_BCK
    sta POINTER_CLUT_DEST+1

    ldy #0
_clut_0_default_loop
    lda (POINTER_CLUT_SRC),y
    sta (POINTER_CLUT_DEST),y
    iny
    cpy #68
    bne _clut_0_default_loop
    stz MMU_IO_CTRL
    rts

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