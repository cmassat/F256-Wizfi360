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
    stz cursor_row
    stz cursor_col
    jsr clearBuffer
    rts

parseChar
    sta currChar
    pha
    lda term_state
    beq _handleNormalChar
    cmp #1
    beq _handleESC
    rts
_handleNormalChar
    pla
    jsr handleNormalChar
    rts
_handleESC
    pla
    jsr handleESC
    rts

;Handle Normal Characters
handleNormalChar
    cmp #ESC
    beq _setESCState
    cmp #$FF
    BCS _end
_print
    jsr screen.writeToScreen
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
    ; jsr printTxBuffer
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
   ; jsr printTxBuffer
    jsr resetTermState
    stz cursor_row
    stz cursor_col
    rts

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
