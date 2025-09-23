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
Y_START = 0
X_START = 0
vt100 .namespace
.section code

init
    jsr resetTermState
    stz term_state
    lda #0
    sta cursor_row
    sta cursor_col
    jsr clearBuffer
    rts

parseChar
    sta currChar
    cmp #ESC
    beq _setESCState
    lda term_state
    cmp #ESCAPE_STATE
    beq _handleESC
_handleNormalChar
    lda currChar
    jsr handleNormalChar
    rts
_handleESC
    lda currChar
    jsr handleESC
    rts
_setESCState
    jsr setESCState
    rts 
; _handleCSI
;     lda currChar
;     jsr handleCSI
;     rts

;Handle Normal Characters
handleNormalChar
    ;beq _end
   ; cmp #ESC
   ; beq _setESCState
    cmp #$f0
    bcs _end
    cmp #$85
    bcs _end
    cmp #10
    beq _lineFeed
    cmp #13
    beq _carriageReturn
    cmp #8
    beq _bkSpace
    cmp #ESC
    beq  _printEsc
_print
    lda currChar
    ldx cursor_col
    ldy cursor_row
    jsr screen.write2Screen8
    jsr incScreenX
_end
    rts
_printEsc
    lda #'^'
    sta currChar
    bra _print
    rts 
; _setTelnet
;     lda #TELNET_STATE
;     sta term_state
;     rts
;_handleTelnet
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

; print_wild
;     lda #' '
;     ldx cursor_col
;     ldy cursor_row
;     jsr screen.write2Screen8
;     rts 

; print_char
;     ldx cursor_col
;     ldy cursor_row
;     jsr screen.write2Screen8
;     jsr vt100.incScreenX
;     rts 

handleESC
    ;lda currChar
    ;jsr print_char
    jsr isEndOfEsc
    bcc _reset
    sec 
    lda currChar
    sta (VT100_ESC_PTR)
    #add1macro VT100_ESC_PTR 
 
 ;  jsr escape__m.handle 
 ;  bcc _reset

    phy 
    jsr escape_A.handle
    ply
    bcc _reset

;    phy 
   ; jsr escape_D.handle
 ;   ply
   ; bcc _reset

    phy 
    jsr escape_H.handle
    ply
    bcc _reset

    phy 
    jsr escape_J.handle
    ply
    bcc _reset

     lda currChar
     cmp #'D'
     bne _next
     jsr debug 
_next 
    jsr escape_catch.handle
    bcc _reset

    sec
    rts
_reset
    jsr resetTermState
    clc
    rts
; _buffer_over_flow
;     jsr debug
;     bra _buffer_over_flow
;     rts 
; _setCSIState
;     lda #2
;     sta term_state
;     rts

setESCState
    ;lda currChar
    ;jsr print_char
    lda #ESCAPE_STATE
    sta term_state
    
    jsr clearBuffer
    lda currChar
    sta (VT100_ESC_PTR)
    #add1macro VT100_ESC_PTR
    rts

resetTermState
    #pushReg
    lda #NORM_STATE
    sta term_state

    #pullReg
    rts

; parseEscape 
;     jsr parseforColorBlk
;     jsr parseReset
;     rts 

; parseforColorBlk
;     ldy #0 
; _loop
;     lda esc_for_bright_black, y 
;     beq _matched  
;     cmp esc_buffer, y 
;     bne _notMatched 
;     iny 
;     bra _loop
;     rts
; _matched   
;     lda scr_color
;     and #$0F 
;     ora #$C0 
;     lda #$C0
;     sta scr_color
;     rts 
; _notMatched
;     rts 


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
    lda vt100.cursor_col
    cmp #79
    bcs _skip

    inc vt100.cursor_col
    rts 
_skip   
    jsr screen.lineFeed
    jsr screen.carriageReturn
    rts

decScreenX
    lda vt100.cursor_col
    cmp #0
    bcc _skip
    dec vt100.cursor_col
    rts 
_skip   
    rts

incScreenY
    lda vt100.cursor_row
    cmp #23
    bcs _skip   

    inc vt100.cursor_row
    rts 
_skip   
    jsr screen.lineFeed
    rts

decScreenY
    lda vt100.cursor_row
    cmp #0
    beq _skip   

    dec vt100.cursor_row
    rts 
_skip   
    rts

subScreenY
    sta posy
    lda vt100.cursor_row
    sec 
    sbc posy
    bmi _setBeginning
    sta vt100.cursor_row
    rts 
_setBeginning
    lda #Y_START
    sta vt100.cursor_row
    rts 


clearBuffer
    #pushReg
    lda #<esc_buffer
    sta VT100_ESC_PTR
    lda #>esc_buffer
    sta VT100_ESC_PTR + 1

    ldy #0
    lda #0
_loop
    sta  esc_buffer, y
    iny
    cpy #16
    bcc _loop
    #pullReg
    rts



; This is a 
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
    jsr debug
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


currChar
    .word $00
    
esc_buffer
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
