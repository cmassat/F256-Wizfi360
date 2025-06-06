startup .namespace
.section code 
init
    stz delay
    stz delay  + 1

    lda <#$c000
    sta SCREEN_POINTER
    lda >#$c000
    sta SCREEN_POINTER + 1

    rts

handle
    jsr init
    jsr terminal.getResponse
    jsr connectToWiFi
_wait
    lda UART_CTRL
    and #2
    bne _wait
    lda UART_DATA
    sta currChar
    jsr terminal.compareReady
    bra _wait
_checkUARTStatus
    rts
printResponse
    lda #2
    sta MMU_IO_CTRL
    lda currChar
    sta (SCREEN_POINTER)
    stz MMU_IO_CTRL

    #add1macro SCREEN_POINTER
    rts

; _okToRead
;     ;jsr printOkToRead

;     bra _checkUARTStatus
;     rts
; _okToSend
;     jsr printOkToSend
;     rts
; _okToWait
;     jsr printWaiting
;     lda #'A'
;     sta UART_DATA
;     lda #$0D
;     sta UART_DATA
;     lda #$0A
;     sta UART_DATA

;     jsr terminal.getResponse
;     jsr printOkToSend

;     rts

; printOkToRead
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okRx, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     lda UART_DATA
;     sta currChar
;     jsr terminal.send2BufferRx
;     rts

; printOkToSend
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okTx, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     jsr atCommand
; _clrBuffer
;     lda UART_CTRL
;     and #4
;     beq _terminalReady
;     lda UART_CTRL
;     and #2
;     bne _clrBuffer
;     lda UART_DATA
;     sta currChar
;     bra _clrBuffer
; _terminalReady
;     jsr terminal.handle
;     rts

; printWaiting
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okWaiting, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     rts
; ;     lda #state.START_APP
; ;     jsr state.is
; ;     bcc _execute

; ;     rts
; ; _execute

; ;     ;jsr clearScreenMemory

; ;     jsr execute
; ;     rts

; ; execute
;     ; jsr atCommand
;     ; jsr terminal.getResponse
;     ; jsr clearScreenMemory
;     ; jsr peekRXBuffer
;    ; jsr atCommand
;    ; jsr terminal.getResponse
;    ; jsr peekRXBuffer
;   ; jsr getWiznetStatus
;     ;jsr peekRXBuffer
;     ;jsr terminal.compareReady
;     ;jsr compareReady
;   ;  bcc _nextState
;    ; jsr compareReady1
;    ; bcc _nextState
;     ;rts
; _nextState
;     ;jsr terminal.emptyWiznetBuffer

;   ;  lda #state.TERMINAL_MODE
;    ; jsr state.set
;   ;  jsr terminal.clearTxBuffer
;  ;   jsr terminal.handle

;    ; jsr peekRXBuffer


;    ; jsr terminal.send2Wiznet
;    ; jsr terminal.getResponse
;    ; jsr terminal.clearTxBuffer
;     rts

; getWiznetStatus
; _wait
;     lda UART_CTRL
;     and #$02
;     bne _waitokToRead
;     ;jsr printOkToRead

;     bra _checkUARTStatus
;     rts
; _okToSend
;     jsr printOkToSend
;     rts
; _okToWait
;     jsr printWaiting
;     lda #'A'
;     sta UART_DATA
;     lda #$0D
;     sta UART_DATA
;     lda #$0A
;     sta UART_DATA

;     jsr terminal.getResponse
;     jsr printOkToSend

;     rts

; printOkToRead
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okRx, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     lda UART_DATA
;     sta currChar
;     jsr terminal.send2BufferRx
;     rts

; printOkToSend
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okTx, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     jsr atCommand
; _clrBuffer
;     lda UART_CTRL
;     and #4
;     beq _terminalReady
;     lda UART_CTRL
;     and #2
;     bne _clrBuffer
;     lda UART_DATA
;     sta currChar
;     bra _clrBuffer
; _terminalReady
;     jsr terminal.handle
;     rts

; printWaiting
;     lda #2
;     sta MMU_IO_CTRL

;     ldy #0
; _loop
;     lda m_okWaiting, y
;     cmp #0
;     beq _end
;     sta $C000, y
;     iny
;     bra _loop
; _end
;     stz MMU_IO_CTRL
;     rts
; ;     lda #state.START_APP
; ;     jsr state.is
; ;     bcc _execute

; ;     rts
; ; _execute

; ;     ;jsr clearScreenMemory

; ;     jsr execute
; ;     rts

; ; execute
;     ; jsr atCommand
;     ; jsr terminal.getResponse
;     ; jsr clearScreenMemory
;     ; jsr peekRXBuffer
;    ; jsr atCommand
;    ; jsr terminal.getResponse
;    ; jsr peekRXBuffer
;   ; jsr getWiznetStatus
;     ;jsr peekRXBuffer
;     ;jsr terminal.compareReady
;     ;jsr compareReady
;   ;  bcc _nextState
;    ; jsr compareReady1
;    ; bcc _nextState
;     ;rts
; _nextState
;     ;jsr terminal.emptyWiznetBuffer

;   ;  lda #state.TERMINAL_MODE
;    ; jsr state.set
;   ;  jsr terminal.clearTxBuffer
;  ;   jsr terminal.handle

;    ; jsr peekRXBuffer


;    ; jsr terminal.send2Wiznet
;    ; jsr terminal.getResponse
;    ; jsr terminal.clearTxBuffer
;     rts

; getWiznetStatus
; _wait
;     lda UART_CTRL
;     and #$02
;     bne _wait
;     lda UART_DATA
;     sta currChar
;     jsr terminal.send2BufferRx
;     jsr compareWiFiConnected
;     bcc _hasWiFi
;     jsr terminal.compareReady
;     bcc _noWifi
;     jsr peekRXBuffer
; _printResponse
;      jsr print_rx
;     bra _wait
; _hasWiFi
;    ; jsr clearBuff
;     jsr terminal.moveToStartBufferTx
;     clc
;   ;  jsr screenHome
;     rts
; _noWifi
;     jsr status.noInternet
;     rts

; compareWiFiConnected
;     LDY #terminal.rxBufferLen - response.wi_fi_message_length
;     ldx #0
; _checkLoop
;     LDA terminal.rxBuffer,Y
;     CMP response.wi_fi_message,x
;     BNE _notEqual
;     INY
;     inx
;     CPY #terminal.rxBufferLen
;     BNE _checkLoop

;     ; All matched!
;     ; Do something here
;     ; e.g., set a flag or jump
;     JMP _matchFound
; _notEqual
;     sec
;     RTS
; _matchFound
;     clc
;     RTS
;      jsr print_rx
;     bra _wait
; _hasWiFi
;    ; jsr clearBuff
;     jsr terminal.moveToStartBufferTx
;     clc
;   ;  jsr screenHome
;     rts
; _noWifi
;     jsr status.noInternet
;     rts

; compareWiFiConnected
;     LDY #terminal.rxBufferLen - response.wi_fi_message_length
;     ldx #0
; _checkLoop
;     LDA terminal.rxBuffer,Y
;     CMP response.wi_fi_message,x
;     BNE _notEqual
;     INY
;     inx
;     CPY #terminal.rxBufferLen
;     BNE _checkLoop

;     ; All matched!
;     ; Do something here
;     ; e.g., set a flag or jump
;     JMP _matchFound
; _notEqual
;     sec
;     RTS
; _matchFound
;     clc
;     RTS

; compareReady
;     LDY #terminal.rxBufferLen - response.ready_message_length
;     ldx #0
; _checkLoop
;     LDA terminal.rxBuffer,Y
;     CMP response.ready_message,x
;     BNE _notEqual
;     INY
;     inx
;     CPY #terminal.rxBufferLen
;     BNE _checkLoop

;     ; All matched!
;     ; Do something here
;     ; e.g., set a flag or jump
;     JMP _matchFound
; _notEqual
;     sec
;     RTS
; _matchFound
;     clc
;     RTS

.endsection 

.section variables 
delay
    .byte $00, $00, $00


.endsection
.endnamespace