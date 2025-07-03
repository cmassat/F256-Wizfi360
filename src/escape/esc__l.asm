;hide show cursor
escape__l .namespace
ESC_CHAR='l'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    clc 
    lda vt100.esc_buffer + 2
    cmp #'?'
    beq _mode 
    bra _skip
    rts
_mode 
    lda vt100.esc_buffer + 3 
    cmp #'2'
    beq _cursor 
    bra _skip  
    rts 
_cursor 
    lda vt100.esc_buffer + 4
    cmp #'5'
    beq _show 
    bra _skip
_show 
    lda #0
    sta vt100.esc_showCursor
    clc
    rts 
_skip
    clc 
    rts 
.endsection
.section  variables
value 
    .byte $00
digit
    .byte $00
index 
    .byte $00
col
    .byte $00
tens 
    .byte 0,10,20,30,40,50,60,70,80,90
.endsection
.endnamespace