; .section code

; initBuffer
;     lda #<terminal.txBuffer
;     sta TX_BUFFER_POINTER

;     lda #>terminal.txBuffer
;     sta TX_BUFFER_POINTER + 1
;     rts

; responseHome
;     lDA #<$C050
;     STA RX_SCRN_POINTER

;     lDA #>$C050
;     STA RX_SCRN_POINTER + 1

;     stz lineNum
;     rts

; screenHome
;     lDA #<$C000
;     STA SCREEN_POINTER

;     lDA #>$C000
;     STA SCREEN_POINTER + 1

;     lda #2
;     sta MMU_IO_CTRL
;     ldy #0
;     lda #32
; _loop
;     sta (SCREEN_POINTER),y
;     iny
;     cpy #80
;     bne _loop
;     stz MMU_IO_CTRL
;     rts


; getKeyStrokes
;     lda mKeyRelease
;     beq _skip
;     stz mKeyRelease
;     jsr peekkeyPress
;     lda mKeypress
;     cmp #0
;     beq _skip
;     cmp #$0D
;     beq _sendKeys
;     cmp #13
;     beq _sendKeys
;     sta (TX_BUFFER_POINTER)

;     ldy #1
;     lda #$0d
;     sta (TX_BUFFER_POINTER),y
;     lda #$0A
;     iny
;     sta (TX_BUFFER_POINTER),y
;     lda (TX_BUFFER_POINTER)
;     jsr send2Screen
;    ; jsr peekTXBufferjsr peekTXBuffer
;     #add1macro SCREEN_POINTER
;     #add1macro TX_BUFFER_POINTER
; _skip
;     rts
; _sendKeys
;     jsr initBuffer
;     jsr send2Wiznet
;     rts

; send2Screen
;     lda #2
;     sta MMU_IO_CTRL
;     lda (TX_BUFFER_POINTER)
;     sta (SCREEN_POINTER)
;     stz MMU_IO_CTRL
;     rts

; send2Wiznet
;     jsr clearScreenMemory
; _sendLoop
;     lda (TX_BUFFER_POINTER)
;     cmp #0
;     beq _done
;     jsr sendChar
;     lda #0
;     sta (TX_BUFFER_POINTER)
;     #add1macro TX_BUFFER_POINTER
;     bra _sendLoop
; _done
;     jsr getResponse
;     jsr initBuffer

;     rts




; send2Buffer
;     ldy #0                 ; index = 0
; _shiftLoop
;     LDA terminal.rxBuffer+1,Y          ; load next byte
;     STA terminal.rxBuffer,Y            ; store it into previous position
;     INY
;     CPY #terminal.rxBufferLen
;     BNE _shiftLoop          ; loop until Y = 7

;     LDA currChar
;     STA terminal.rxBuffer+terminal.rxBufferLen -1         ; insert new byte at the end
;     rts

; isDone
;     pha
;     phx
;     phy

;     jsr compareOK
;     bcc _end
;     jsr compareError
;     bcc _end
; _end
;     ply
;     plx
;     pla
;     rts
; _wait
;     lda UART_CTRL
;     and #4
;     ldx UART_DATA
;     bne _wait
;     rts





; compareOK
;     LDY #terminal.rxBufferLen - ok_message_length
;     ldx #0
; _checkLoop
;     LDA rxBuffer,Y
;     CMP ok_message,x
;     BNE _notEqual
;     INY
;     inx
;     CPY #rxBufferLen
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

; compareError
;     LDY #rxBufferLen - error_message_length
;     ldx #0
; _checkLoop
;     LDA rxBuffer,Y
;     CMP error_message,x
;     BNE _notEqual
;     INY
;     inx
;     CPY #rxBufferLen
;     BNE _checkLoop

;     ; All matched!
;     ; Do something here
;     ; e.g., set a flag or jump
;     JMP _matchFound
; _notEqual
;     sec
;     RTS
; _matchFound
;   ;  jsr clearBuff
;     clc
;     RTS

; add1macro .macro address
;     lda \address
;     clc
;     adc #1
;     sta \address

;     lda \address + 1
;     clc
;     adc #0
;     sta \address + 1

; .endmacro
; .endsection
; .section variables


; error_message
;     .text 'ERROR',$0D
; error_message_end
; error_message_length = error_message_end - error_message

; ok_message
;     .text 'OK',$0D
; ok_message_end
; ok_message_length = ok_message_end - ok_message

; .endsection
