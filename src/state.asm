
state .namespace
.section code 
MENU = 0
TERMINAL = 1
ADD_INPUT = 2
init
    stz mCurrentState
    rts 

set 
    sta mCurrentState
    rts

isState 
    cmp mCurrentState
    beq _yes
    sec 
    rts 
_yes
    clc 
    rts 

.endsection
.section variables
mCurrentState 
    .byte $00
.endsection
.endnamespace