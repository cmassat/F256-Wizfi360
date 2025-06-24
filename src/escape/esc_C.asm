;Cursor Right
escape_C .namespace
ESC_CHAR='C'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    lda #2            ; skip ESC and '['
    sta index
    lda #0
    sta value

parse
    ldy index

    lda vt100.esc_buffer, y
    cmp #ESC_CHAR
    beq _done_parsing
    cmp #'9'+1
    bcs _done_parsing
     ; Convert ASCII digit to binary
    jsr build
    inc index
    jsr parse
    rts
_done_parsing 
    lda index 
    cmp #0 
    bne _move
    lda #1 
    sta value 
_move
    lda vt100.cursor_col 
    clc 
    sbc value 
    sta vt100.cursor_col  
    sta col

    ;lda vt100.cursor_col 
    ;cmp #MAX_LENGTH - 1
    ;bcs _reset
    clc
    rts
_reset 
    lda #MAX_LENGTH - 1
    sta vt100.cursor_col
    sta col
    clc 
    rts 

build 
    sta digit  
    lda index
    cmp #3 
    beq _addones
    cmp #2
    bne _end
    lda digit
    sec
    sbc #'0'              ; A = digit value (0–9)
    sta digit
    lda digit 
    tax 
    lda tens,x
    clc  
    adc value 
    sta value
    bra _end 
_addones
    lda digit
    sec
    sbc #'0'              ; A = digit value (0–9)
    sta digit
    lda value 
    clc 
    adc digit
    sta value 
_end
    rts  
.endsection
.section  variables
value 
    .byte $00

temp1
    .byte $00
temp2
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