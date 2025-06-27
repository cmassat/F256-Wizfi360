escape_catch .namespace
.section code 
handle
    lda vt100.currChar
    cmp #'n'
    beq _parse
    cmp #'M'
    beq _parse
    cmp #'J'
    beq _parse
    cmp #'J'
    beq _parse
    cmp #'K'
    beq _parse
    cmp #'S'
    beq _parse
    cmp #'T'
    beq _parse
    cmp #'f'
    beq _parse
    cmp #'s'
    beq _parse
    cmp #'u'
    beq _parse
    cmp #'h'
    beq _parse
    cmp #'l'
    beq _parse
    sec 
    rts 
_parse
    jsr app.printBuffer

    clc
    rts 
.section variables
.endsection
.endsection
.endnamespace