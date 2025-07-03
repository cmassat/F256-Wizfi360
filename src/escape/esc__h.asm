;Cursor LEFT
escape__h .namespace
ESC_CHAR='h'
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
    lda #1 
    sta vt100.esc_showCursor
    clc
    rts 
_skip
    clc 
    rts 
.endsection
.section  variables

.endsection
.endnamespace