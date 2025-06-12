add1macro .macro address
    lda \address
    clc
    adc #1
    sta \address

    lda \address + 1
    adc #0
    sta \address + 1

.endmacro

clearScreen
    lda #2
    sta MMU_IO_CTRL
    lda #$20
    ldx #0
_loop
    sta $C000,x
    sta $C000 + 255 ,x
    sta $C000 + 510 ,x
    sta $C000 + 765 ,x
    sta $C000 + 1020 ,x
    inx
    cpx #0
    bne _loop
    stz MMU_IO_CTRL
    rts