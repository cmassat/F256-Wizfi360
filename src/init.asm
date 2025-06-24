init .namespace
.section code
wiznet
    jsr setWiFiMode
    jsr delay
    jsr setSingleMode
    jsr delay
    jsr setTransMode
    jsr delay
    rts

setWiFiMode
    #pushReg
    ldy #0
_loop
    lda AT_WIFI_MODE, y
    cmp #0
    beq _done_wiFi
    sta txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta txBuffer,y
    jsr app.sendCommand
    #pullReg
    rts

setSingleMode
    #pushReg
    ldy #0
_loop
    lda AT_SINGLE_MODE, y
    cmp #0
    beq _done_wiFi
    sta txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta txBuffer,y
    jsr app.sendCommand
    #pullReg
    rts


setTransMode
    #pushReg
    ldy #0
_loop
    lda AT_TRANS_MODE, y
    cmp #0
    beq _done_wiFi
    sta txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta txBuffer,y
    jsr app.sendCommand
    #pullReg
    rts



screenInit
    ;INIT POINTERS
    lda #<$c000
    sta TX_SCREEN_PTR
    lda #>$c000
    sta TX_SCREEN_PTR + 1

    lda screen.screenPos
    sta SCREEN_PTR
    lda screen.screenPos + 1
    sta SCREEN_PTR + 1

    lda #<txBuffer
    sta TX_BUFFER_PTR
    lda #>txBuffer
    sta TX_BUFFER_PTR + 1

    lda #<txBufferSent
    sta TX_SENT_PTR
    lda #>txBufferSent
    sta TX_SENT_PTR + 1

    stz txReady
    lda #1
    sta mlineNum

    rts
.endsection
.section variables
.endsection
AT_WIFI_MODE
    .text "AT+CWMODE=1",0     ; "AT\r\n" + null terminator
AT_SINGLE_MODE
    .text "AT+CIPMUX=0",0     ; "AT\r\n" + null terminator
AT_TRANS_MODE
    .text "AT+CIPMODE=1",0     ; "AT\r\n" + null terminator
.endnamespace

