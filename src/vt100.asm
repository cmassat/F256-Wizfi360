;STATE_NORMAL      ; Normal character processing
;STATE_ESC         ; Just saw ESC (0x1B)
;STATE_CSI         ; Just saw ESC [
;STATE_ESC_PAREN   ; Just saw ESC (
ESCAPE_STATE = 1
TELNET_STATE = 2
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
    ;pha
    lda term_state
    beq _handleNormalChar
    cmp #ESCAPE_STATE
    beq _handleESC
    cmp #TELNET_STATE
    beq _handleTelnet
    rts
_handleNormalChar
    lda currChar
    jsr handleNormalChar
    rts
_handleESC
    lda currChar
    jsr handleESC
    rts
; _handleCSI
;     lda currChar
;     jsr handleCSI
;     rts
_handleTelnet
    jsr handleTelnet
    rts 
;Handle Normal Characters
handleNormalChar
    cmp #ESC
    beq _setESCState
    ;cmp #$FF
    ;beq _setTelnet
_print
    jsr screen.writeToScreen
_end
    rts
_setESCState
    lda #ESCAPE_STATE
    sta term_state
    jsr clearBuffer
    lda currChar
    sta (VT100_ESC_PTR)
    #add1macro VT100_ESC_PTR
    rts
_setTelnet
    lda #TELNET_STATE
    sta term_state
    rts
; handleCSI
;     lda currChar
;     sta (VT100_ESC_PTR)
;     rts 
; Handle ESC Sequence
handleESC
    jsr isEndOfEsc
    bcc _reset
    ;lda rcv_char
    lda currChar
    sta (VT100_ESC_PTR)
   ; jsr screen.writeToScreen
    #add1macro VT100_ESC_PTR
    lda currChar
    cmp #'m'
    beq _reset
    lda currChar
    cmp #'D'
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
    jsr parseEscape
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

parseEscape 
    jsr parse23Up
    jsr parseforColorBlk
    jsr parseReset
    jsr parseCharLeft
    rts 


parse23Up
    ldy #0 
_loop
    lda esc_23Up, y 
    beq _matched  
    cmp esc_buffer, y 
    bne _notMatched 
    iny 
    bra _loop
    rts
_matched   
    lda <#$C000 
    sta SCREEN_PTR
    lda #>$c000 
    sta SCREEN_PTR + 1
    stz mlineNum
    rts 
_notMatched
    rts 

parseforColorBlk
    ldy #0 
_loop
    lda esc_for_bright_black, y 
    beq _matched  
    cmp esc_buffer, y 
    bne _notMatched 
    iny 
    bra _loop
    rts
_matched   
    lda scr_color
    and #$0F 
    ora #$C0 
    lda #$C0
    sta scr_color
    rts 
_notMatched
    rts 


parseReset
    ldy #0 
_loop
    lda esc_reset, y 
    beq _matched  
    cmp esc_buffer, y 
    bne _notMatched 
    iny 
    bra _loop
    rts
_matched   
    lda #$50
    sta scr_color
    rts 
_notMatched
    rts 

parseCharLeft 
    ldy #0 
_loop
    lda esc_curLft, y 
    beq _matched  
    cmp esc_buffer, y 
    bne _notMatched 
    iny 
    bra _loop
    rts
_matched   
    #sub1macro SCREEN_PTR
    rts 
_notMatched
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



isEndOfEsc 
    lda VT100_ESC_PTR 
    cmp <#buffer_end
    beq _checkHi
    sec 
    rts 
_checkHi 
    lda VT100_ESC_PTR + 1 
    cmp >#buffer_end
    beq  _isEnd
    sec
    rts 
_isEnd
    clc 
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

scr_color 
    .byte $50



esc_for_bright_black
    .text ESC, '[90m',0
esc_reset    
    .text ESC, '[0m',0

esc_curLft
    .text ESC, '[D',0

esc_23Up
    .text ESC, '[23A',0
.endsection
.endnamespace
