tx .namespace
.section code
init 
    jsr clearTxBuffer
;_loop
;    
;    bra _loop
    rts

sendCommand
   
    #A8
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
    stz txReady
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
    #A8
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