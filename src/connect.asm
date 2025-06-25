connect .namespace
.section code 

initBuffer
    lda #0
    sta m_port 
    sta m_port + 1
    sta m_port + 2
    sta m_port + 3
    sta m_port + 3
    rts 
show
    ;jsr setEchoOff
    ;jsr app.sendCommand
   
    jsr waitASec
    jsr clearScreen
    ldy #0
    lda #0
_loop 
    sta m_address, y  
    iny 
    cpy #80 
    bne _loop
    jsr clearSendBuffer
    jsr printAddressPrompt
    jsr getAddress
    jsr printPortPrompt
    jsr getPort
    jsr buildCommand
    jsr app.sendCommand
    jsr waitASec
    jsr setSendMode
    jsr app.sendCommand
    jsr waitASec
    jsr clearScreen
    jsr initBuffer
    lda #1
    sta mIsConnected
    stz vt100.cursor_col
    stz vt100.cursor_row
    jsr app.mainApp
   
  ; bra show
    rts

printAddressPrompt
    lda <#m_label_address
    sta SCROLL_SRC_PTR
    lda >#m_label_address
    sta SCROLL_SRC_PTR + 1

    lda <#$C000
    sta SCROLL_DEST_PTR
    lda >#$C000
    sta  SCROLL_DEST_PTR + 1
    lda #2
    sta MMU_IO_CTRL

    ldx #0
_loop
    lda (SCROLL_SRC_PTR)
    cmp #0
    beq _done
    cmp #10
    beq _nextLine
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_SRC_PTR
    #add1macro SCROLL_DEST_PTR
    bra _loop
_done
    stz MMU_IO_CTRL
    rts
_nextLine
    inx
    inx
    lda screen.screenPos,x
    sta SCROLL_DEST_PTR
    inx
    lda screen.screenPos,x
    sta SCROLL_DEST_PTR + 1
    dex
    #add1macro SCROLL_SRC_PTR
    bra _loop
    rts

;X is line number

setScreenPosition
    txa
    asl
    lda screen.screenPos,x
    sta SCROLL_DEST_PTR
    inx
    lda screen.screenPos,x
    sta  SCROLL_DEST_PTR + 1
    dex
    rts

printPortPrompt
    ldx #4
    jsr setScreenPosition

    lda <#m_label_port
    sta SCROLL_SRC_PTR
    lda >#m_label_port
    sta SCROLL_SRC_PTR + 1

    lda #2
    sta MMU_IO_CTRL
_loopPort
    lda (SCROLL_SRC_PTR)
    cmp #0
    beq _done
    cmp #10
    beq _nextLine
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_SRC_PTR
    #add1macro SCROLL_DEST_PTR
    bra _loopPort
_done
    stz MMU_IO_CTRL
    rts
_nextLine
    inx
    inx
    lda screen.screenPos,x
    sta SCROLL_DEST_PTR
    inx
    lda screen.screenPos,x
    sta SCROLL_DEST_PTR + 1
    dex
    #add1macro SCROLL_SRC_PTR
    bra _loopPort
    rts

getAddress
    lda #<m_address
    sta MENU_BUFFER_PTR
    lda #>m_address
    sta MENU_BUFFER_PTR + 1
    jsr setFrameTimer
    jsr screen.setDebounceTimer
_wait
    jsr handleEvents
    jsr screen.isOkToPrint
    bcs _wait
    lda mKeyPress
    cmp #0
    beq _wait
    lda mKeyPress
    cmp #8
    beq _backup_buffer
    cmp #13  ;I think this the foenix cr/lf    not sure if #10 does anything
    beq _end
    sta (MENU_BUFFER_PTR)
    pha
    lda #2
    sta MMU_IO_CTRL
    pla
    sta (SCROLL_DEST_PTR)
    stz MMU_IO_CTRL
    #add1macro MENU_BUFFER_PTR
    #add1macro SCROLL_DEST_PTR
    jsr screen.setDebounceTimer
    bra _wait
    rts
_backup_buffer
    lda #$20
    sta (SCROLL_DEST_PTR)
    lda #0
    sta (MENU_BUFFER_PTR)

    #sub1macro SCROLL_DEST_PTR
    #sub1macro MENU_BUFFER_PTR

    lda #2
    sta MMU_IO_CTRL
    lda #$20
    sta (SCROLL_DEST_PTR)
    stz MMU_IO_CTRL

    lda #0
    sta (MENU_BUFFER_PTR)
    jsr screen.setDebounceTimer
    ; lda #$20
    ; sta (SCROLL_DEST_PTR)
    ; lda #0
    ; sta (MENU_BUFFER_PTR)
    ; #sub1macro SCROLL_DEST_PTR
    ; #sub1macro MENU_BUFFER_PTR

    ; lda #2
    ; sta MMU_IO_CTRL
    ; lda #$20
    ; sta (SCROLL_DEST_PTR)
    ; stz MMU_IO_CTRL

    ; lda #0
    ; sta (MENU_BUFFER_PTR)
    ; jsr screen.setDebounceTimer
     bra _wait
    rts
_end
    lda #0
    sta (MENU_BUFFER_PTR)
    rts

checkAddressMaxLength
    lda #<MENU_BUFFER_PTR
    cmp #<m_address_end
    beq _checkHi
    sec
    rts
_checkHi
    lda #>MENU_BUFFER_PTR
    cmp #>m_address_end
    beq _yes
    sec
    rts
_yes
    clc
    rts

isPortMaxLength
    lda MENU_BUFFER_PTR
    cmp #<m_port_end
    beq _checkHi
    sec
    rts
_checkHi
    lda MENU_BUFFER_PTR + 1
    cmp #>m_port_end
    beq _yes
    sec
    rts
_yes
    clc
    rts

isPortMinLength
    lda MENU_BUFFER_PTR
    cmp #<m_port
    beq _checkHi
    sec
    rts
_checkHi
    lda MENU_BUFFER_PTR + 1
    cmp #>m_port
    beq _yes
    sec
    rts
_yes
    clc
    rts

getPort
    lda #<m_port
    sta MENU_BUFFER_PTR
    lda #>m_port
    sta MENU_BUFFER_PTR + 1
    jsr setFrameTimer
    jsr screen.setDebounceTimer
_wait
    jsr handleEvents
    jsr screen.isOkToPrint
    bcs _wait
    lda mKeyPress
    cmp #0
    beq _wait
    lda mKeyPress
    cmp #8
    beq _backup_buffer
    cmp #13  ;I think this the foenix cr/lf    not sure if #10 does anything
    beq _end
    sta (MENU_BUFFER_PTR)
    pha
    lda #2
    sta MMU_IO_CTRL
    pla
    sta (SCROLL_DEST_PTR)
    stz MMU_IO_CTRL
    jsr isPortMaxLength
    bcc _noInc
    #add1macro MENU_BUFFER_PTR
    #add1macro SCROLL_DEST_PTR
_noInc
    jsr screen.setDebounceTimer
    bra _wait
    rts
_backup_buffer
    jsr backupBuffer
    bra _wait
_end
    lda #0
    sta (MENU_BUFFER_PTR)
    rts

backupBuffer
    jsr isPortMinLength
    bcs _okToBackUp
    rts
_okToBackUp
    jsr screen.isOkToPrint
    bcs _wait
    lda #$20
    sta (SCROLL_DEST_PTR)
    lda #0
    sta (MENU_BUFFER_PTR)
    lda #0
    sta (MENU_BUFFER_PTR)

    #sub1macro SCROLL_DEST_PTR
    #sub1macro MENU_BUFFER_PTR

    lda #2
    sta MMU_IO_CTRL
    lda #$20
    sta (SCROLL_DEST_PTR)
    stz MMU_IO_CTRL

    lda #0
    sta (MENU_BUFFER_PTR)
    jsr screen.setDebounceTimer
_wait
    rts
_end
    rts

clearSendBuffer
    #pushReg
    ldy #0
    lda #0
_loop
    sta m_send_buffer,y
    iny
    cpy #0
    bne _loop
    #pullReg
    rts

buildCommand
    lda #<txBuffer
    sta MENU_BUFFER_PTR
    lda #>txBuffer
    sta MENU_BUFFER_PTR + 1

    jsr buildTCPCommand
    jsr buildAddress
    jsr buildPort
    rts

buildTCPCommand
    ldy #0
_loop
    lda m_AT_CONNECT, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    rts

buildAddress
    ldy #0
_loop
    lda m_address, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    lda #'"'
    sta (MENU_BUFFER_PTR)
    #add1macro MENU_BUFFER_PTR
    lda #','
    sta (MENU_BUFFER_PTR)
    #add1macro MENU_BUFFER_PTR
    rts

buildPort
    ldy #0
_loop
    lda m_port, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    #add1macro MENU_BUFFER_PTR
    rts


setSendMode
    lda #<txBuffer
    sta MENU_BUFFER_PTR
    lda #>txBuffer
    sta MENU_BUFFER_PTR + 1
   ldy #0
_loop
    lda m_AT_SEND, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    lda #0
    sta (MENU_BUFFER_PTR)
    rts

setEchoOff
    lda #<txBuffer
    sta MENU_BUFFER_PTR
    lda #>txBuffer
    sta MENU_BUFFER_PTR + 1
   ldy #0
_loop
    lda m_AT_ECHO_OFF, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    lda #0
    sta (MENU_BUFFER_PTR)
    rts


hangup  
    jsr waitASec
    jsr waitASec
    lda #<txBuffer
    sta MENU_BUFFER_PTR
    lda #>txBuffer
    sta MENU_BUFFER_PTR + 1

    lda #$2b
    sta (MENU_BUFFER_PTR)
    #add1macro MENU_BUFFER_PTR

    lda #$2b
    sta (MENU_BUFFER_PTR)
    #add1macro MENU_BUFFER_PTR

    lda #$2b
    sta (MENU_BUFFER_PTR)
    #add1macro MENU_BUFFER_PTR

    lda #0
    sta (MENU_BUFFER_PTR)
    
    jsr app.sendLogoff
    jsr waitASec
    jsr waitASec   
    jsr closeConnection

    lda #0
    sta mIsConnected
    rts

VIA_BASE   = $DC00
VIA_T1CL   = VIA_BASE + $04
VIA_T1CH   = VIA_BASE + $05
VIA_IFR    = VIA_BASE + $0D
VIA_IER    = VIA_BASE + $0E
TIMER_LOW  = $E8
TIMER_HIGH = $FD
waitASec
    ldx #101                  ; Number of timer loops

wait_loop
    lda #TIMER_LOW
    sta VIA_T1CL              ; Load Timer 1 low first
    lda #TIMER_HIGH
    sta VIA_T1CH              ; Writing high starts the countdown

wait_for_t1
    lda VIA_IFR
    and #%01000000            ; Bit 6 = Timer 1 interrupt flag
    beq wait_for_t1

    lda #%01000000            ; Clear T1 interrupt flag
    sta VIA_IFR

    dex
    bne wait_loop

    rts 

closeConnection    
    lda #<txBuffer
    sta MENU_BUFFER_PTR
    lda #>txBuffer
    sta MENU_BUFFER_PTR + 1
   ldy #$00
_loop
    lda m_AT_CLOSE, y
    cmp #0
    beq _end
    sta (MENU_BUFFER_PTR)
    iny
    #add1macro MENU_BUFFER_PTR
    bra _loop
_end
    lda #0
    sta (MENU_BUFFER_PTR)
    jsr app.sendCommand
    rts

.endsection 

.section variables 
.endsection

; m_DISSCONECT 
;  .text '+++',0
m_wait 
    .byte $00
m_AT_ECHO_OFF
    .text 'ATE0',0

m_AT_ECHO_ON
    .text 'ATE1',0

m_AT_SEND
    .text 'AT+CIPSEND',0

m_AT_CONNECT
    .text 'AT+CIPSTART="TCP","',0

m_AT_CLOSE 
    .text 'AT+CIPCLOSE',0

m_send_buffer
    .fill 255

m_address
    .fill 80
m_address_end

m_port
    .byte $00, $00, $00, $00, $00
m_port_end

m_label_address
    .text 'Enter Address: "www.somebbs.org" then hit enter',10
    .text '-> '
    .byte $0

m_label_port
    .text 'Enter Port Number ',10
    .text '-> '
    .byte $0
.endnamespace