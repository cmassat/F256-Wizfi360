;A Is Cursor UP
escape_A .namespace
ESC_CHAR=$41
MAX_LENGTH = 24
.section code 
handle
    ldy #2
    lda vt100.esc_buffer, y
    cmp #ESC_CHAR
    beq _parse
    iny
    lda vt100.esc_buffer, y
    cmp #ESC_CHAR
    beq _parse_one
    iny
    lda vt100.esc_buffer, y
    cmp #ESC_CHAR
    beq _parse_tens
    sec 
    rts 
_parse
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenY
    ; jsr vt100.print_wild
    clc
    rts 
_parse_one

    jsr parse_one
    jsr move_cursor
    clc
    rts 
_parse_tens
    jsr parse_tens
    jsr move_cursor

    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    clc
    rts 
parse_one 
    stz digit
    lda vt100.esc_buffer + 2
    jsr ones_to_int
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    ; jsr vt100.decScreenX
    ; jsr vt100.print_wild
    rts 

move_cursor
    lda digit 
    jsr vt100.subScreenY
    
    rts 
parse_tens
    stz digit
    lda vt100.esc_buffer + 3
    sec 
    sbc #'0' 
    sta digit 
    lda vt100.esc_buffer + 2
    sec 
    sbc #'0'
    tax
    lda tens,x
    clc 
    adc digit
    sta digit 
    rts 

ones_to_int
    sta digit 
    lda digit 
    sec 
    sbc #'0'
    sta digit
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