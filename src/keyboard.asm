kbd .namespace
.section code

init 
    stz mDebounce
    stz mKeyPress
    rts

getKey
    lda mDebounce
    cmp #0
    bne _skip 
    lda mKeyPress
    cmp #0 
    beq _skip
    lda #20
    sta mDebounce
    lda mKeyPress
    stz mKeyPress
    rts 
_skip
    stz mKeyPress
    lda #0
    rts 

isReady 
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
     
    lda #%00001000
    rts 

is_1_pressed
    lda mKeyPress
    cmp #'1'
    beq _yes  
    sec 
    rts 
_yes
    stz mKeyPress
    clc  
    rts 

.endsection 
.section variables



.endsection  
.endnamespace 