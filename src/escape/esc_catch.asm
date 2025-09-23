escape_catch .namespace
.section code 
handle
    jsr checkUpper 
    bcc _ok
    jsr checkLower
    bcc _ok
    sec 
    rts 
_ok
    clc 
    rts 


checkUpper
    lda vt100.currChar
    cmp #$41
    bcs _ok_caps
    sec
    rts 
_ok_caps
    cmp #$5A 
    bcc _ok_l
    beq _ok_l
    sec
    rts
_ok_l
    clc
    rts 

checkLower
    lda vt100.currChar
    cmp #$61
    bcs _ok_caps
    sec
    rts 
_ok_caps
    cmp #$7A 
    bcc _ok_l
    beq _ok_l
    sec 
    rts
_ok_l
    clc
    rts 
.section variables
.endsection
.endsection
.endnamespace