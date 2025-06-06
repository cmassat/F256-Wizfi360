state .namespace
.section code
init
    lda #START_APP
    sta currentState
    rts

is
    cmp currentState
    beq _yes
_no
    sec
    rts
_yes
    clc
    rts

set
    sta currentState
    rts
.endsection

.section variables
START_APP = 0
TERMINAL_MODE = 1

currentState
    .byte $00
.endsection
.endnamespace