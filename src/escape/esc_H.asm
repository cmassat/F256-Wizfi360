;Cursor LEFT
escape_H .namespace
ESC_CHAR='H'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.esc_buffer + 2
    cmp #ESC_CHAR
    beq _parse
    ;lda vt100.esc_buffer + 3
    ;cmp #ESC_CHAR
    ;beq _parse
    ;lda vt100.esc_buffer + 4
    ;cmp #ESC_CHAR
    ;beq _parse
    sec 
    rts 
_parse
    lda #0
    sta vt100.cursor_col
    lda #0
    sta vt100.cursor_row
    jsr debug
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