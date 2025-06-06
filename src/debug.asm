peekRXBuffer
    pha
    phx
    phy
    lda #<$CC30 + 160 + 80
    sta DEBUG_POINTER

    lda #>$CC30 + 160 + 80
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL

    ldy #0
_loop
    lda terminal.rxBuffer, y
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    #add1macro DEBUG_POINTER

    lda terminal.rxBuffer, y
    and #$0f
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    #add1macro DEBUG_POINTER
    #add1macro DEBUG_POINTER

    iny
    cpy #terminal.rxBufferLen + 1
    bne _loop
    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts


peekTXBuffer
     pha
    phx
    phy
    lda #<$CC30
    sta DEBUG_POINTER

    lda #>$CC30
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL

    ldy #0
_loop
    lda terminal.txBuffer, y
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #1
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1

    lda terminal.txBuffer, y
    and #$0f
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #2
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1
    iny
    cpy #40
    bne _loop

    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts


peekkeyPress
    pha
    phx
    phy
    lda #<$D0E0
    sta DEBUG_POINTER

    lda #>$D0E0
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL



    lda mKeyPress
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #1
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1

    lda mKeyPress
    and #$0f
    tax
    lda hex_values , x
    sta (DEBUG_POINTER)
    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts

watch_UART_CTRL_TX
      pha
    phx
    phy
    lda #<$D090
    sta DEBUG_POINTER

    lda #>$D090
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL



    lda UART_CTRL
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #1
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1

    lda UART_CTRL
    and #$0f
    tax
    lda hex_values,x
    sta (DEBUG_POINTER)
    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts

watch_UART_CTRL_RX
      pha
    phx
    phy
    lda #<$D093
    sta DEBUG_POINTER

    lda #>$D093
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL



    lda mUART_CTRL_RX
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #1
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1

    lda mUART_CTRL_RX
    and #$0f
    tax
    lda hex_values
    sta (DEBUG_POINTER)
    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts