tx .namespace
.section code
init 
    jsr clearTxBuffer
    rts


sendToBuffer
    lda mKeypressbak
    cmp #$0d
    beq _sendCRLF
    jsr tx.sendChar
    rts 
_sendCRLF
    lda #13
    jsr sendChar
    lda #10
    jsr sendChar
    rts 

sendCommand    
    phy
    ldy #0
_loop
    lda txBuffer, y
    cmp #0
    beq _end
    jsr SendChar
    lda #'B'
    sta txBuffer, y
    iny
    bra _loop
   
_end
    lda #13
    jsr sendChar
    lda #10
    jsr sendChar
    ply
    jsr clearTxBuffer
    rts

SendChar
    pha
WaitTX
    lda UART_CTRL
    and #CTRL_TX_EMPTY       ; Bit 2 = TX ready
    cmp #CTRL_TX_EMPTY
    bne WaitTX
    pla
    sta UART_DATA
    rts

clearTxBuffer
    pha
    phx
    phy

    ldy #0
_loop
    lda #0
    sta txBuffer, y
    iny
    cpy #100
    bne _loop
    ply
    plx
    pla
    rts
.endsection 

.section variables
isEcho 
    .byte $00

txBuffer
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.endsection
.endnamespace