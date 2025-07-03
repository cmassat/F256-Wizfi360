kbd .namespace
.section code

init 
    #A16 
    stz mDebounce
    stz mKeyPress
    rts

getKey 
    #A8
    jsr isReady
    lda $D658
    cmp #0
    beq _skip
    tax 
    stx mKeyPress
    jsr setTimer
    ldx mKeyPress
    txa
    stz mKeyPress
    rts 
_skip
    lda #0
    rts

isReady 
    #A8 
    ldx mDebounce
    txa 
    beq _yes 
    lda $D659
    cmp #20 
    bcs _yes 
    sec 
    rts
_yes 
    ldx #0 
    stx mDebounce
    clc
    rts
_no 
    sec 
    clc 

setTimer 
    #A8 
    lda #%00001000
    rts 
.endsection 
.section variables
.align 2 
mKeyPress 
    .word $00 
mDebounce 
    .word $00
.endsection  
.endnamespace 