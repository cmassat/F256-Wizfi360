;STATE_NORMAL      ; Normal character processing
;STATE_ESC         ; Just saw ESC (0x1B)
;STATE_CSI         ; Just saw ESC [
;STATE_ESC_PAREN   ; Just saw ESC (
ESC     = $1B
CSI     = '['         ; part of ESC sequences
LPAREN  = '('
ZERO    = '0'
B       = 'B'
J       = 'J'
H       = 'H'


vt100 .namespace
.section code

init
    jsr resetTermState
    lda #<esc_buffer
    sta VT100_ESC_PTR
    lda #>esc_buffer
    sta VT100_ESC_PTR + 1
    jsr clearBuffer
    rts

parseChar
    sta currChar
    pha
    lda term_state
    beq _handleNormalChar
    cmp #1
    beq _handleESC
    ; cmp #2
    ; beq _handleCSI
    ; cmp #3
    ; beq _handleESCParen
   ; pla
    rts
_handleNormalChar
    pla
    jsr handleNormalChar
    rts
_handleESC
    pla
    jsr handleESC
    rts
; _handleCSI
;     pla
;     jsr handleCSI
;     rts
; _handleESCParen
;     pla
;     jsr handleESCParen
    rts


;Handle Normal Characters
handleNormalChar
    cmp #ESC
    beq _setESCState
    ; Otherwise: printable character
 ;   jsr PrintChar      ; your routine to draw to screen
    ;  cmp #13
    ; beq _print
    ; cmp #10
    ; beq _print
    cmp #$FF
    BCS _end
_print
    jsr screen.writeToScreen
    ;jsr screen.setDebounceTimer
_end
    rts
_setESCState
    pha
    lda #1
    sta term_state
    jsr clearBuffer
    pla
    sta (VT100_ESC_PTR)
   ; jsr screen.writeToScreen
   ; jsr screen.setDebounceTimer
    #add1macro VT100_ESC_PTR
    rts


; Handle ESC Sequence
handleESC
    ;lda rcv_char
    lda currChar
    sta (VT100_ESC_PTR)
    jsr screen.writeToScreen
    #add1macro VT100_ESC_PTR
    lda currChar
    cmp #'m'
    beq _reset
    lda currChar
    cmp #'B'
    beq _reset
    lda currChar
    cmp #'J'
    beq _reset
    lda currChar
    cmp #'H'
    beq _H
    lda currChar
    cmp #'h'
    beq _lowerh
    lda currChar
    cmp #'C'
    beq _reset
    lda currChar
    cmp #'n'
    beq _reset
    lda currChar
    cmp #'u'
    beq _reset
    lda currChar
    cmp #'s'
    beq _reset
    ; cmp #CSI         ; '['
    ; beq _setCSIState
    ; cmp #LPAREN      ; '('
    ; beq _setESCParen
    ; ; Unknown ESC sequence
    ; lda #0
    ; sta term_state
     jsr printTxBuffer
    rts
_reset
    jsr resetTermState
    rts
_H
    jsr handleH
    rts
_lowerh
    jsr handleLowerh
    rts
_setCSIState
    lda #2
    sta term_state
    rts
handleLowerh
    jsr resetTermState
    rts
handleH
   ; lda currChar
   ; sta (VT100_ESC_PTR)
   ; stz seperator
    jsr printTxBuffer
    jsr resetTermState
;     ldy #0
; _loop
;     lda esc_buffer, y
;     cmp #'H'
;     beq _end
;     cmp #';'
;     beq _seperatror
; _next
;     iny
;     bne _loop
; _end
    lda <#$C000
    sta SCREEN_PTR
    lda >#$C000
    sta SCREEN_PTR + 1
    stz mlineNum

;     jsr printTxBuffer
;     rts
; _seperatror
;     inc seperator
;     bra _next
    rts
; _setESCParen
;     lda #3
;     sta term_state
;     rts
;
; CSI
;
; handleCSI
;     cmp #'m'
;     beq _done
;    ; lda rcv_char
;     cmp #'0'
;     bcc CheckCSICommand
;     cmp #'9'+1
;     bcs CheckCSICommand
;     ; It's a digit
;     sec
;     sbc #'0'
;     asl parse_val
;     asl parse_val
;     adc parse_val
;     sta parse_val
;     rts
; _done
;     lda #0
;     sta (VT100_ESC_PTR)
;     jsr resetTermState
;     rts

; CheckCSICommand
;     cmp #';'
;     bne NotSemicolon
;     lda parse_val
;     sta tmp_row
;     lda #0
;     sta parse_val
;     rts

; NotSemicolon
;     cmp #'H'
;     bne NotH
;     lda #<$c000
;     sta TX_SCREEN_PTR
;     lda #>$c000
;     sta TX_SCREEN_PTR + 1
;     ; lda parse_val
;     ; sta tmp_col
;     ; lda tmp_row
;     ; sta cursor_row
;     ; lda tmp_col
;     ; sta cursor_col
;     jmp ResetTermState

; NotH
;     cmp #J
;     bne ResetTermState
;     lda parse_val
;     cmp #2
;     bne ResetTermState
;     jsr ClearScreen
;     jmp ResetTermState
;lda
;     cmp #B
;     beq SetASCIICharset
;     ; unknown
;     jmp ResetTermState

; SetAltCharset
;     lda #1
;     sta use_alt_charset
;     jmp ResetTermState

; SetASCIICharset
;     lda #0
;     sta use_alt_charset
;     jmp ResetTermState

resetTermState
    lda #0
    sta term_state
    ;#setPointer VT100_ESC_PTR, esc_buffer
     lda #<esc_buffer
     sta VT100_ESC_PTR
     lda #>esc_buffer
     sta VT100_ESC_PTR + 1
    rts

clearBuffer
    #pushReg
    ldy #0
    lda #0
_loop
    sta  esc_buffer, y
    iny
    cpy #32
    bcc _loop
    #pullReg
    rts

.endsection

.section variables


seperator       .byte  0
term_state      .byte  0       ; current parser state
cursor_row      .byte  0       ; current row
cursor_col      .byte  0       ; current column
tmp_row         .byte  0       ; for parsing ESC [ r ; c H
tmp_col         .byte  0
parse_val       .byte  0       ; for building numbers
use_alt_charset .byte  0       ; flag for line drawing

  .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
 .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
     .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
     .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
     .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
     .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

currChar
    .byte $00
esc_buffer
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
buffer_end
.endsection
.endnamespace