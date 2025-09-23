wizfi .namespace
.section code
init
    jsr setWiFiMode
_loop    
    

   ; jsr kbd.getKey
   ; jsr vt100.parseChar
    
    jsr rx.readResponse
    
  ;  bra _loop 
    ; jsr delay
    ; jsr setSingleMode
    ; jsr delay
    ; jsr setTransMode
    ; jsr delay
   ; stz txReady
    rts

setWiFiMode
    ldy #0
_loop
    lda AT_WIFI_MODE, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
   jsr tx.sendCommand


    rts

setSingleMode
    #pushReg
    ldy #0
_loop
    lda AT_SINGLE_MODE, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts


setTransModeNon
    #pushReg
    
    ldy #0
_loop
    lda AT_TRANS_MODE_NON, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

setTransMode
    #pushReg
    
    ldy #0
_loop
    lda AT_TRANS_MODE, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

setPassThruMode
    #pushReg
    
    ldy #0
_loop
    lda AT_TRANSMISSION_MODE, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

setStopIPD
    #pushReg
    
    ldy #0
_loop
    lda AT_STOP_IPD, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

setEchoOff
    #pushReg
    ldy #0
_loop
    lda AT_ECHO_OFF, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

connect_telehack
    #pushReg
    
    ldy #0
_loop
    lda AT_TELEHACK, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts

connect_starwars
    #pushReg
    
    ldy #0
_loop
    lda AT_STAR_WARS, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    
    #pullReg
    rts


close 
      #pushReg
    ldy #0
_loop
    lda AT_CLOSE, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendCommand
    #pullReg
    rts 

logoff
    #pushReg
    jsr waitSecond
    jsr waitSecond
    ldy #0
_loop
    lda AT_LOG_OFF, y
    cmp #0
    beq _done_wiFi
    sta tx.txBuffer,y
    iny
    bra _loop
_done_wiFi
    iny
    lda #0
    sta tx.txBuffer,y
    jsr tx.sendString
    jsr debug
    jsr waitSecond
    jsr waitSecond
    jsr close
    #pullReg
    rts

waitSecond
   ldx #0
_loopOuter
   ldy #0
_loop 
    iny
    cpy #0
    bne _loop 
    inx 
    cpx #0
    bne _loopOuter
    rts 
; screenInit
;     ;INIT POINTERS
;     lda #<$c000
;     sta TX_SCREEN_PTR
;     lda #>$c000
;     sta TX_SCREEN_PTR + 1

;     lda screen.screenPos
;     sta SCREEN_PTR
;     lda screen.screenPos + 1
;     sta SCREEN_PTR + 1



;     lda #<txBufferSent
;     sta TX_SENT_PTR
;     lda #>txBufferSent
;     sta TX_SENT_PTR + 1

   
;     lda #1
;     sta mlineNum

;     rts
.endsection
.section variables
isLogoff
    .byte 0
AT_WIFI_MODE
    .text "AT+CWMODE=1",0     ; "AT\r\n" + null terminator
AT_SINGLE_MODE
    .text "AT+CIPMUX=0",0     ; "AT\r\n" + null terminator
AT_TRANS_MODE_NON
    .text "AT+CIPMODE=0",0     ; "AT\r\n" + null terminator

AT_TRANS_MODE
    .text "AT+CIPMODE=1",0 

AT_TRANSMISSION_MODE
    .text "AT+CIPSEND",0     ; "AT\r\n" + null terminator
AT_ECHO_OFF 
     .text "ATE0",0 

AT_STOP_IPD 
    .text 'AT+CIPRXGET=1',0
AT_TELEHACK
    .text 'AT+CIPSTART="TCP","telehack.com",23',0

AT_STAR_WARS
    .text 'AT+CIPSTART="TCP","starwarstel.net",23',0
AT_CLOSE 
    .text "AT+CIPCLOSE",0

AT_LOG_OFF
    .text '+++',0
.endsection
.endnamespace

