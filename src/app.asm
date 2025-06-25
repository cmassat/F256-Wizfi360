app .namespace
.section code
mainApp
    lda #1
    sta mIsInit

_appLoop
    jsr handleEvents
    lda mKeyPress
    cmp #$88
    beq _menu
    cmp #$87
    beq _hangUp
    lda mKeyPress
    
    jsr getInput

    lda txReady
    cmp #1
    beq _txData
_handleRead
    jsr _rxData ;buffer not empty, so read date
  ;  bra _handle
    rts
_txData
    jsr sendCommand
    bra _handleRead
    rts
_rxData
    jsr wiz.ReadResponse
    bra _appLoop
    rts
_menu
    stz mKeyPress
    jsr menu.show
    rts
_hangUp
    stz mKeyPress
    jsr connect.hangup
    jsr _appLoop
    rts

; Send a single character (in A)
getInput
    lda mIsConnected
    cmp #1
    beq _sendNow
    lda txReady
    cmp #0
    bne _skipKeyPress
    jsr screen.isOkToPrint
    bcs _skipKeyPress
    lda mKeyPress
    cmp #0
    beq _skipKeyPress
    lda mKeyPress
    cmp #8
    beq _backup_buffer
    cmp #13  ;I think this the foenix cr/lf    not sure if #10 does anything
    beq _okToSendTx
    sta (TX_BUFFER_PTR)
     #add1macro TX_BUFFER_PTR
_skipBuffer
    lda mKeyPress
     jsr screen.writeToScreen
     jsr screen.setDebounceTimer
_skipKeyPress
    rts
_backup_buffer
    pha
    lda #0
    sta (TX_BUFFER_PTR)
    lda TX_BUFFER_PTR
    sec
    sbc #1
    sta TX_BUFFER_PTR

    lda TX_BUFFER_PTR + 1
    sbc #0
    sta TX_BUFFER_PTR + 1
    lda #0
    sta (TX_BUFFER_PTR)
    dec vt100.cursor_col
    jsr screen.setDebounceTimer
    pla
    bra _skipBuffer
    rts
_okToSendTx
    lda #0
    sta (TX_BUFFER_PTR)
    lda #1
    sta  txReady
    jsr _skipBuffer
_end
    rts
_sendNow
    jsr sendNow 
    rts

sendNow
    ;jsr handleEvents
    jsr screen.isOkToPrint
    bcs _skipKeyPress
    lda mKeyPress
    sta tmpKey
    cmp #0 
    beq _skipKeyPress
    lda mKeyPress
    cmp #$0D
    beq _sendEnd
    lda mKeyPress
    cmp #8
    beq _skipKeyPress
    jsr sendChar
    lda mKeyPress
    jsr screen.writeToScreen
    jsr screen.setDebounceTimer
_skipKeyPress
    rts 

_sendEnd
    jsr screen.writeToScreen
    jsr screen.setDebounceTimer
    lda #$0D 
    jsr sendChar
    lda #$0A
    jsr sendChar
    stz mKeyPress
    rts 
sendLogoff
   lda #<txBuffer
    sta TX_BUFFER_PTR
    lda #>txBuffer
    sta TX_BUFFER_PTR + 1
    phy
    ldy #0
_loop
    lda txBuffer, y
    cmp #0
    beq _end
    jsr SendChar
    iny
    bra _loop
_end
    ply
    stz txReady
    rts 


sendCommand
    lda #<txBuffer
    sta TX_BUFFER_PTR
    lda #>txBuffer
    sta TX_BUFFER_PTR + 1
    phy
    ldy #0
_loop
    lda txBuffer, y
    cmp #0
    beq _end
    jsr SendChar
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
   ; lda #13
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
    cpy #10
    bne _loop
    ply
    plx
    pla
    rts
.endsection
.section variables
.endsection
.endnamespace
