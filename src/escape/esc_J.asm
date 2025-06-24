;Cursor LEFT
escape_J .namespace
ESC_CHAR='J'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    jsr clearScreen
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