app .namespace
.section code
mainApp
   lda #1
   sta mIsInit

_handle
    #bit8 
    jsr handleEvents
    #bit16
    lda mKeyPress
    cmp #$88
    beq _menu

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
    jsr rx.readResponse
    bra _handle
    rts
_menu
    stz mKeyPress
    jsr menu.show

    rts
; Send a single character (in A)
getInput
    lda connect.m_isConnected
    cmp #1
    beq _instantSend
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
_instantSend
    lda mKeyPress
    jsr sendChar
     jsr screen.writeToScreen
     jsr screen.setDebounceTimer
    rts 
; ReadResponse
; _readLoop
;     jsr read_uart_data
;     bcs _doneRead
;     sta tmpChar 
;     lda tmpChar
;     jsr rollRxBuffer
;     lda tmpChar
;     jsr vt100.parseChar
; _doneRead     ; Null-terminate
;     rts

; rollRxBuffer
;     ldy #0
;     ldx #1
; _loop
;     lda rxBuffer, x
;     sta rxBuffer,y
;     inx
;     iny
;     cpy #7
;     bne _loop
;     dey
;     lda tmpChar 
;     sta rxBuffer,y
;     rts





.endsection

.endnamespace
