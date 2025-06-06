; tcpOutput
;     stz bufferCharCount
; _wait
;     bcc _end
;     lda UART_CTRL
;     and #$02
;     bne _wait
;     lda UART_DATA
;     sta currChar

;     jsr print
;     jsr peekBuffer
;    ; bcc _end
;     bra _wait
; _end
;     rts


singleConnectMode
    rts

peekBuffer
    lda #<$C780
    sta DEBUG_POINTER

    lda #>$C780
    sta DEBUG_POINTER + 1

    lda #2
    sta MMU_IO_CTRL

    ldy #0
_loop
    lda terminal.txBuffer, y
    lsr
    lsr
    lsr
    lsr
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #1
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1

    lda terminal.txBuffer, y
    and #$0f
    tax
    lda hex_values, x
    sta (DEBUG_POINTER)

    lda DEBUG_POINTER
    clc
    adc #2
    sta DEBUG_POINTER

    lda DEBUG_POINTER + 1
    adc #0
    sta DEBUG_POINTER + 1
    iny
    cpy #terminal.txBufferLen
    bne _loop
    stz MMU_IO_CTRL
    rts



; trackBuffer
;     LDY #0                 ; index = 0
; ShiftLoop:
;     LDA commBuffer+1,Y          ; load next byte
;     STA commBuffer,Y            ; store it into previous position
;     INY
;     CPY #commBufferLen
;     BNE ShiftLoop          ; loop until Y = 7

;     LDA currChar
;     STA commBuffer+commBufferLen          ; insert new byte at the end
;     rts

; CompareConnected:
;     LDY #0
; CheckLoop:
;     LDA commBuffer,Y
;     CMP ConnectedString,Y
;     BNE NotEqual
;     INY
;     CPY #8
;     BNE CheckLoop

;     ; All matched!
;     ; Do something here
;     ; e.g., set a flag or jump
;     JMP MatchFound

; NotEqual:
;     ; Mismatch
;     ; handle non-match
;     RTS

; MatchFound:
;     ; Match logic
;     RTS

bufferCharCount
    .byte $0



ConnectedString:
    .byte "C","O","N","N","E","C","T","E","D"
