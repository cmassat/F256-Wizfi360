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
    rts


parseChar
    pha
    lda term_state
    beq _handleNormalChar
   ; cmp #1
    bra _handleESC
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
  ;  cmp #ESC
  ;  beq _setESCState
    ; Otherwise: printable character
 ;   jsr PrintChar      ; your routine to draw to screen
    cmp #$FF
    BCS _end
_print
    jsr screen.writeToScreen
    jsr screen.setDebounceTimer
_end
    rts
_setESCState
    pha
    lda #1
    sta term_state
    jsr clearBuffer
    pla
    sta (VT100_ESC_PTR)
    #add1macro VT100_ESC_PTR
    rts


; Handle ESC Sequence
handleESC
    ;lda rcv_char

    sta (VT100_ESC_PTR)
    pha
    #add1macro VT100_ESC_PTR
    pla
    cmp #'m'
    beq _reset
    cmp #'B'
    beq _reset
    cmp #'J'
    beq _reset
    cmp #'H'
    beq _reset
    cmp #'C'
    beq _reset
    cmp #'n'
    beq _reset
    cmp #'u'
    beq _reset
    ; cmp #CSI         ; '['
    ; beq _setCSIState
    ; cmp #LPAREN      ; '('
    ; beq _setESCParen
    ; ; Unknown ESC sequence
    ; lda #0
    ; sta term_state
    rts
_reset
    jsr resetTermState
    rts

_setCSIState
    lda #2
    sta term_state
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



term_state      .byte  0       ; current parser state
cursor_row      .byte  0       ; current row
cursor_col      .byte  0       ; current column
tmp_row         .byte  0       ; for parsing ESC [ r ; c H
tmp_col         .byte  0
parse_val       .byte  0       ; for building numbers
use_alt_charset .byte  0       ; flag for line drawing
esc_buffer
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
buffer_end
.endsection
.endnamespace