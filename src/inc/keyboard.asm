.section code
keyboardTimer
    jsr resetAnyKey
    lda mKeyboardDelay
    cmp #0
    bne _delay
    rts
_delay
    dec mKeyboardDelay
    rts 
resetKeys
    stz mKeyboardDelay
    stz mKeyboardResetAnyKey
    stz mAnyKey
    stz mKeyW
    stz mKeyA
    stz mKeyS
    stz mKeyD
    stz mKeyL
    stz mKeySP
    stz mKeyF1
    stz mKeyLeft
    stz mKeyRight
    stz mKeyDown
    rts

resetAnyKey
    lda mKeyboardResetAnyKey
    cmp #0
    bne _delay
    stz mAnyKey
    rts
_delay
    dec mKeyboardResetAnyKey
    rts


keyboardAnykey
    lda mKeyboardDelay
    sta mKeyboardDelay
    lda #15
    sta mKeyboardResetAnyKey
    rts
    
keyboardPressed
    jsr set_w_pressed
    jsr set_a_pressed
    jsr set_s_pressed
    jsr set_d_pressed
    jsr set_l_pressed
    jsr set_F1_pressed
    jsr set_space_pressed
    jsr set_left_pressed
    jsr set_right_pressed
    jsr set_down_pressed
    rts
keyboardReleased
    jsr set_w_released
    jsr set_a_released
    jsr set_s_released
    jsr set_d_released
    jsr set_l_released
    jsr set_F1_released
    jsr set_space_released
    jsr set_left_released
    jsr set_right_released
    jsr set_down_released
    rts
resetControls
    stz mKeyW
    stz mKeyA
    stz mKeyS
    stz mKeyD
    rts 
keyPressMacro .macro
    lda mKeyPress
    cmp #\2
    beq _yes
    rts
_yes
    lda #1 
    sta \1
    stz mKeyPress
.endmacro


set_a_pressed
    #keyPressMacro mKeyA, 'a'
    rts

set_a_released
    lda mKeyRelease
    cmp #'a'
    beq _yes
    rts
_yes
    stz mKeyA
    rts

isAnyKeyPressed
    lda mKeyboardDelay
    cmp #0
    beq _checkAnyKey
    sec
    rts
_checkAnyKey
    lda mAnyKey
    cmp #1
    beq _yes
    sec
    rts
_yes
    stz mAnyKey
    clc
    rts

set_d_pressed
    #keyPressMacro mKeyD, 'd'
    rts

set_d_released
    lda mKeyRelease
    cmp #'d'
    beq _yes
    rts
_yes
    stz mKeyD
    rts

set_l_pressed
    #keyPressMacro mKeyL, 'l'
    rts

set_l_released

    lda mKeyRelease
    cmp #'l'
    beq _yes
    rts
_yes
    stz mKeyL
    rts

set_s_pressed
    #keyPressMacro mKeyS, 's'
    rts

set_s_released
    lda mKeyRelease
    cmp #'s'
    beq _yes
    rts
_yes
    stz mKeyS
    rts

set_q_pressed
    lda mKeyPress
    cmp #'q'
    beq _yes
    rts
_yes
    rts

set_w_pressed
    #keyPressMacro mKeyW, 'w'
    rts


; left arrow
set_left_pressed
    #keyPressMacro mKeyLeft, $02
    rts

set_left_released
    lda mKeyRelease
    cmp #$02
    beq _yes
    rts
_yes
    stz mKeyLeft
    rts

isLeftPressed
    lda mKeyLeft
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

; right arrow
set_right_pressed
    #keyPressMacro mKeyRight, $06
    rts

set_right_released
     lda mKeyRelease
    cmp #$06
    beq _yes
    rts
_yes
    stz mKeyRight
    rts

isRightPressed
    lda mKeyRight
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

; down arrow
set_down_pressed
    #keyPressMacro mKeyDown, $0E
    rts

set_down_released
     lda mKeyRelease
    cmp #$0E
    beq _yes
    rts
_yes
    stz mKeyDown
    rts

isDownPressed
    lda mKeyDown
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

set_f1_pressed
    #keyPressMacro mKeyF1, $81
    rts

set_f1_released
    lda mKeyRelease
    cmp #$81
    beq _yes
    rts
_yes
    stz mKeyF1
    rts

set_w_released
    lda mKeyRelease
    cmp #'w'
    beq _yes
    rts
_yes
    stz mKeyW
    rts

set_space_pressed
    #keyPressMacro mKeySP, $20
    rts

set_space_released
    lda mKeyRelease
    cmp #$20
    beq _yes
    rts
_yes
    stz mKeySP
    rts

isNWPressed
    lda mKeyW
    cmp #1
    beq _checkA
    sec
    rts
 _checkA
    lda mKeyA
    cmp #1
    beq _yes
    sec
    rts
_yes
    clc
    rts


isNEPressed
    lda mKeyW
    cmp #1
    beq _checkD
    sec
    rts
 _checkD
    lda mKeyD
    cmp #1
    beq _yes
    sec
    rts
_yes
    clc
    rts


isWPressed
    lda mKeyW
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

isSWPressed
    lda mKeyA
    cmp #1
    beq _checkS
    sec
    rts
 _checkS
    lda mKeyS
    cmp #1
    beq _yes
    sec
    rts
_yes
    clc
    rts

isSEPressed
    lda mKeyD
    cmp #1
    beq _checkS
    sec
    rts
 _checkS
    lda mKeyS
    cmp #1
    beq _yes
    sec
    rts
_yes
    clc
    rts

isAPressed
    lda mKeyA
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

isSpacePressed
    lda mKeySP
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

isSPressed
    lda mKeyS
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

isDPressed
    lda mKeyD
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts

isF1Pressed
    lda mKeyF1
    cmp #1
    beq _yes
    sec
    rts
 _yes
    clc
    rts
.endsection

.section variables
keyboardDelayTimer = 10
mKeyboardDelay
    .byte $00
mKeyboardResetAnyKey
    .byte $00
mAnyKey
    .byte $00
mKeyW
    .byte $00
mKeyA
    .byte $00
mKeyS
    .byte $00
mKeyD
    .byte $00
mKeyL
    .byte $00
mKeySP
    .byte $00
mKeyF1
    .byte $00
mKeyLeft
    .byte $00
mKeyRight
    .byte $00
mKeyDown
    .byte $00
.endsection