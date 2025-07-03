;STATE_NORMAL      ; Normal character processing
;STATE_ESC         ; Just saw ESC (0x1B)
;STATE_CSI         ; Just saw ESC [
;STATE_ESC_PAREN   ; Just saw ESC (
NORM_STATE = 0
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
    ;jsr resetTermState
    
    lda #0
    sta cursor_row
    sta cursor_col
    jsr clearBuffer
    rts

parseChar
    #A8
    tax 
    stx currChar
    ;pha
    lda term_state
    beq _handleNormalChar
    cmp #ESCAPE_STATE
    beq _handleESC
  ;  cmp #TELNET_STATE
  ;  beq _handleTelnet
    rts
_handleNormalChar
    ldx currChar
    txa
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

;Handle Normal Characters
handleNormalChar
    beq _end
    cmp #ESC
    beq _setESCState
   ; cmp #$ff 
   ; beq _handleTelnet
    cmp #$85
    bcs _end
    cmp #10
    beq _lineFeed
    cmp #13
    beq _carriageReturn
    cmp #8
    beq _bkSpace
_print
    lda currChar
    ldx cursor_col
    ldy cursor_row
    jsr screen.write2Screen8
    jsr incScreenX
_end
    rts
_setESCState
    lda #ESCAPE_STATE
    sta term_state
    jsr clearBuffer
    lda currChar
    sta (VT100_ESC_PTR)
   ; jsr screen.writeToScreen
    #add1macro VT100_ESC_PTR
    rts
_setTelnet
    lda #TELNET_STATE
    sta term_state
    rts
_handleTelnet
  ;  jsr telnet.handleTelnet
    rts 
_lineFeed 
   
   ; jsr carriageReturn
    jsr incScreenY
    rts
_carriageReturn
   ;jsr linefeed 
    ldx #0 
    stx cursor_col
    rts 
_bkSpace
    jsr decScreenX
    rts



handleESC
    jsr isEndOfEsc
    bcc _reset
    ;lda rcv_char
    lda currChar
    sta (VT100_ESC_PTR)
   ; jsr screen.writeToScreen
    #add1macro VT100_ESC_PTR
    
    jsr escape__h.handle 
    bcc _reset

    jsr escape__l.handle 
    bcc _reset
    
    jsr escape_A.handle
    bcc _reset
    
    jsr escape_B.handle
    bcc _reset
    
    jsr escape_C.handle
    bcc _reset
    
    jsr escape_D.handle
    bcc _reset 
    
    jsr escape_E.handle
    bcc _reset 

    jsr escape_F.handle
    bcc _reset 

    jsr escape_G.handle
    bcc _reset 

    jsr escape_H.handle
    bcc _reset 

    jsr escape_J.handle
    bcc _reset 
    jsr escape_catch.handle
    bcc _reset

    lda currChar
    cmp #'m'
    beq _reset
    rts
_reset
    jsr resetTermState
    jsr parseEscape
    rts
_setCSIState
    lda #2
    sta term_state
    rts


resetTermState
    lda #NORM_STATE
    sta term_state
;     ;#setPointer VT100_ESC_PTR, esc_buffer
;     lda #<esc_buffer
;     sta VT100_ESC_PTR
;     lda #>esc_buffer
;     sta VT100_ESC_PTR + 1
     rts

parseEscape 
    jsr parseforColorBlk
    jsr parseReset
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
    lda esc_buffer, y 
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

incScreenX
    #A16
    lda vt100.cursor_col
    cmp #79
    bcs _skip

    inc vt100.cursor_col
    rts 
_skip   
    rts

decScreenX
    #A16
    lda vt100.cursor_col
    cmp #0
    bcc _skip
    dec vt100.cursor_col
    rts 
_skip   
    rts

incScreenY
    #A16
    lda vt100.cursor_row
    cmp #24
    bcs _skip   

    inc vt100.cursor_row
    rts 
_skip   
    rts

decScreenY
    #A16
    lda vt100.cursor_row
    cmp #0
    beq _skip   

    dec vt100.cursor_row
    rts 
_skip   
    rts



clearBuffer
    #pushReg
    ldy #0
    lda #0
_loop
    sta  esc_buffer, y
    iny
    iny
    cpy #16
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


;seperator       .byte  0
term_state      .word  0       ; current parser state
cursor_row      .word  0       ; current row
cursor_col      .word  0       ; current column
;tmp_row         .byte  0       ; for parsing ESC [ r ; c H
;tmp_col         .byte  0
parse_val       .byte  0       ; for building numbers
use_alt_charset .byte  0       ; flag for line drawing

.align 2
currChar
    .word $00
    
esc_buffer
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
buffer_end

scr_color 
    .byte $50

posX
    .byte $00
posy
    .byte $99


esc_for_bright_black
    .text ESC, '[90m',0
esc_reset    
    .text ESC, '[0m',0

esc_showCursor 
    .byte $00
.endsection
.endnamespace
.include "./escape/main.asm"
