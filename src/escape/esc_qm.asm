;Cursor LEFT
escape_qm .namespace
ESC_CHAR='?'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.esc_buffer + 2
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    lda vt100.esc_buffer + 5
    cmp #'h'
    beq _checkEnable
    clc
    rts

_checkEnable
    ;25
    ;turn on cursor 
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