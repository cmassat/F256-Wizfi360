terminal .namespace
.section code 
moveToStartBufferTx
    lda #<txBuffer
    sta TX_BUFFER_POINTER

    lda #>txBuffer
    sta TX_BUFFER_POINTER + 1
    rts

moveToStartBufferRx
    lda #<rxBuffer
    sta RX_BUFFER_POINTER

    lda #>rxBuffer
    sta RX_BUFFER_POINTER + 1

    phy
    ldy #0
_loop
    lda #0
    sta (RX_BUFFER_POINTER),y
    iny
    cpy #rxBufferLen
    bne _loop
    ply
    rts

handle
   ; jsr clearScreenMemory
    jsr moveToStartBufferTx
    jsr emptyWiznetBuffer
    jsr handleKeyStrokes

    rts

handleKeyStrokes
    ;jsr initEvents
    jsr handleEvents
    lda mKeyRelease
    beq handleKeyStrokes
    stz mKeyRelease
  ;  jsr peekTXBuffer
    lda mKeypress
    cmp #0
    beq _skip
    cmp #$0D
    beq _sendKeys
    cmp #13
    beq _sendKeys
    sta (TX_BUFFER_POINTER)

    ldy #1
    lda #$0d
    sta (TX_BUFFER_POINTER),y
    lda #$0A
    iny
    sta (TX_BUFFER_POINTER),y
    lda (TX_BUFFER_POINTER)
    jsr send2ScreenTx

    #add1macro SCREEN_POINTER
    #add1macro TX_BUFFER_POINTER
_skip
    bra handleKeyStrokes
    rts
_sendKeys
    jsr moveToStartBufferTx
    jsr send2Wiznet
    jsr handleKeyStrokes
    rts


send2Wiznet
    jsr peekTXBuffer
_sendLoop
    lda (TX_BUFFER_POINTER)
    cmp #0
    beq _done
    jsr sendChar
    lda #0
    sta (TX_BUFFER_POINTER)
    #add1macro TX_BUFFER_POINTER
    bra _sendLoop
_done
    ;jsr clearTxBuffer
    jsr getResponse
    jsr moveToStartBufferTx

    rts

send2ScreenTx
    lda #2
    sta MMU_IO_CTRL
    lda (TX_BUFFER_POINTER)
    sta (SCREEN_POINTER)
    stz MMU_IO_CTRL
    rts

send2ScreenRx
    lda #2
    sta MMU_IO_CTRL
    lda currChar
    sta (SCREEN_POINTER)
    #add1macro SCREEN_POINTER
    stz MMU_IO_CTRL
    rts

getResponse
  ;  jsr responseHome
_wait
    lda UART_CTRL
   ; cmp #0
   ; beq _end
    and #$02
    bne _wait
    lda UART_DATA
    sta currChar
    jsr send2BufferRx
    jsr send2ScreenRx
    jsr isDone
    bcc _end
    bra _wait
_end
    jsr moveToStartBufferTx
    jsr screenHome
    jsr peekRXBuffer
    clc
    rts

emptyWiznetBuffer
_wait
    lda UART_CTRL
    and #4
    beq _end
    lda UART_CTRL
    and #$02
    bne _wait
    lda UART_DATA
    bra _wait
_end
    rts


send2BufferRx
    phy
    ldy #0                 ; index = 0
_shiftLoop
    LDA rxBuffer+1,Y          ; load next byte
    STA rxBuffer,Y            ; store it into previous position
    INY
    CPY #11
    BNE _shiftLoop          ; loop until Y = 7

    LDA currChar
    STA rxBufferEnd   ; insert new byte at the end
    ply
    rts

isDone
    pha
    phx
    phy
    jsr compareOK
    bcc _end
    jsr compareError
    bcc _end
    jsr compareReady
    bcc _end
_end
    ply
    plx
    pla
    rts
_wait
    lda UART_CTRL
    and #4
    ldx UART_DATA
    bne _wait
    rts

compareError
    LDY #rxBufferLen - response.error_message_length - 1
    ldx #0
_checkLoop
    LDA rxBuffer,Y
    CMP response.error_message,x
    BNE _notEqual
    INY
    inx
    CPY #rxBufferLen
    BNE _checkLoop

    ; All matched!
    ; Do something here
    ; e.g., set a flag or jump
    JMP _matchFound
_notEqual
    sec
    RTS
_matchFound
  ;  jsr clearBuff
    clc
    RTS


compareReady
    phy
    LDY #0
_checkLoop
    LDA RX_BUFFER_POINTER,Y
    CMP response.ready_message,y
    BNE _notEqual
    INY
    CPY #response.ready_message_length
    BNE _checkLoop

    ; All matched!
    ; Do something here
    ; e.g., set a flag or jump
    JMP _matchFound
_notEqual
    ply
    sec
    RTS
_matchFound
    ply
    clc
    RTS

responseHome
    lDA #<$C050
    STA RX_SCRN_POINTER

    lDA #>$C050
    STA RX_SCRN_POINTER + 1

    stz lineNum
    rts

compareOK
    LDY #rxBufferLen - response.ok_message_length -1
    ldx #0
_checkLoop
    LDA rxBuffer,Y
    CMP response.ok_message,x
    BNE _notEqual
    INY
    inx
    CPY #rxBufferLen
    BNE _checkLoop

    ; All matched!
    ; Do something here
    ; e.g., set a flag or jump
    JMP _matchFound
_notEqual
    sec
    RTS
_matchFound
    clc
    RTS

screenHome
    lDA #<$C000
    STA SCREEN_POINTER

    lDA #>$C000
    STA SCREEN_POINTER + 1

    lda #2
    sta MMU_IO_CTRL
    ldy #0
    lda #32
_loop
    sta (SCREEN_POINTER),y
    iny
    cpy #80
    bne _loop
    stz MMU_IO_CTRL
    rts

clearTxBuffer
    ldx #0
_loop
    lda #0
    sta txBuffer,x
    inx
    cpx #txBufferLen
    bcc _loop
    lda #$0d
    sta txBuffer

    lda #$0a
    sta txBuffer+1
    rts
.endsection 

.section variables
txBuffer
    .fill 80
txBufferEnd
txBufferLen=txBufferEnd-txBuffer
rxBuffer
    .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0
rxBufferEnd
    .byte $0
rxBufferLen=rxBufferEnd-rxBuffer
.endsection
.endnamespace