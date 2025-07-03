;hide show cursor
escape__m .namespace
ESC_CHAR='m'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    jsr first 
    bcs _end 
   ; jsr second 
   ; bcs _end 
   ; jsr third
_end
    lda #$50
    sta vt100.scr_color
    clc 
    rts

first
    lda vt100.esc_buffer + 2
    cmp #';'
    beq _firstChar
    cmp #'m'
    bne _chkStyle
    jsr _chkStyle
    sec 
    rts 
_chkStyle
    lda vt100.esc_buffer + 3
    cmp #';'
    beq _style
    cmp #'m'
    bne _check2 
    jsr _style
    sec 
    rts 
_check2
    lda vt100.esc_buffer + 4
    cmp #';'
    beq _check2digit
    cmp #'m'
    bne _check3
    jsr _check2digit
    sec 
    rts 
_check3 
    lda vt100.esc_buffer + 4
    cmp #';'
    beq _check3digit
    cmp #'m'
    bne _done 
    jsr _check3digit
    sec 
    rts 
_done 
    clc
    rts 
_style 
    lda #3
    sta fisrtSemi
    lda vt100.esc_buffer + 2
    sec 
    sbc #'0' 
    sta value
    lsr value
    jsr style
    rts 
_firstChar
    lda #2 
    sta fisrtSemi
    rts 
_check2digit
    lda #4
    sta fisrtSemi   
    lda vt100.esc_buffer + 2
    sec 
    sbc #'0'
    tax 
    lda tens, x
    sta value  
 
    lda vt100.esc_buffer + 3
    tax 
    lda tens, x
    sec
    sbc #'0' 
    clc 
    adc value 
    sta value 
    lda value

    cmp #40
    bcc _for 
    bcs _back
    rts
_check3digit
    lda #5
    sta fisrtSemi
    lda vt100.esc_buffer + 4 
    jsr styleFor
    rts 
_for 
    lda value
    and #$0f
    jsr styleFor
    rts 
_back
    lda value
    and #$0f
    jsr styleBack
    rts 
second 
    ldy fisrtSemi
    iny
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _firstChar
    cmp #'m'
    bne _check1 
    jsr _firstChar
    sec 
    rts 
_check1
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _style
    cmp #'m'
    bne _check2 
    jsr _style
    sec 
    rts 
_check2 
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _check2digit
    cmp #'m'
    bne _check3
    jsr _check2digit
    sec 
    rts 
_check3 
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _check3digit
    cmp #'m'
    bne _done
    clc
    rts
_done 
    clc
    rts
_firstChar
    tya
    sta secondSemi
    clc 
    rts 
_style 
    tya 
    sta secondSemi
    ldy secondSemi
    dey 
    lda vt100.esc_buffer,y 
    jsr style 
    clc 
    rts 
_check2digit
    tya 
    sta secondSemi
    ldy secondSemi
    dey 
    dey 
    lda vt100.esc_buffer,y 
    cmp #'3'
    beq _for 
    cmp #'4'
    beq _back
    clc  
    rts
_check3digit
    tya 
    sta secondSemi
    dey
    lda vt100.esc_buffer,y
    jsr styleFor
    clc 
    rts 
_for 
    ldy secondSemi
    dey 
    lda vt100.esc_buffer,y 
    jsr styleFor
    clc 
    rts 
_back
    ldy secondSemi
    dey 
    lda vt100.esc_buffer,y 
    lda vt100.esc_buffer + 3
    jsr styleBack
    clc
    rts 

third
    ldy secondSemi
    iny
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _firstChar
    cmp #'m'
    bne _check1 
    jsr _firstChar
    sec 
    rts 
_check1 
    beq _firstChar
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _style
     cmp #'m'
    bne _check2 
    jsr _style
    sec 
    rts 
_check2  
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _check2digit
    cmp #'m'
    bne _check3
    jsr _check2digit
    sec 
    rts 
_check3 
    iny 
    lda vt100.esc_buffer,y 
    cmp #';'
    beq _check3digit
    cmp #'m'
    bne _done 
    jsr _check3digit
    sec 
_done 
    clc
    rts
_firstChar
    tya
    sta thirdSemi
    clc 
    rts 
_style 
    tya 
    sta thirdSemi
    ldy thirdSemi
    dey 
    lda vt100.esc_buffer,y 
    jsr style 
    clc
    rts 
_check2digit
    tya 
    sta thirdSemi
    ldy thirdSemi
    dey 
    dey 
    lda vt100.esc_buffer,y 
    cmp #'3'
    beq _for 
    cmp #'4'
    beq _back 
    clc
    rts
_check3digit
    tya 
    sta thirdSemi
    dey
    lda vt100.esc_buffer,y
    jsr styleFor
    clc
    rts 
_for 
    ldy thirdSemi
    dey 
    lda vt100.esc_buffer,y 
    jsr styleFor
    clc
    rts 
_back
    ldy thirdSemi
    dey 
    lda vt100.esc_buffer,y 
    lda vt100.esc_buffer + 3
    jsr styleBack
    clc
    rts 

style
    cmp #'0'
    beq _resetStyle
    cmp #'1'
    beq _bold
    cmp #'3'
    beq _italic 
    cmp #'4'
    beq _underline 
    clc
    rts
_resetStyle
    lda #$50
    sta vt100.scr_color
    clc
    rts
_bold 
    clc
    rts 
_italic
    clc
    rts
_underline
    clc
    rts

styleFor
    cmp #0
    beq _colorFor0
    cmp #1
    beq _colorFor1
    cmp #2
    beq _colorFor2
    cmp #3
    beq _colorFor3
    cmp #4
    beq _colorFor4
    cmp #5
    beq _colorFor5
    cmp #6
    beq _colorFor6
    cmp #7
    beq _colorFor7
    rts
_colorFor0
    lda vt100.scr_color
    and #$0f 
    sta vt100.scr_color
    rts 
_colorFor1
    lda vt100.scr_color
    and #$0f 
    and #$2f
    sta vt100.scr_color
    rts 
_colorFor2
    lda vt100.scr_color
    and #$0f 
    and #$5f
    sta vt100.scr_color
    rts 
_colorFor3
    lda vt100.scr_color
    and #$0f 
    and #$7f
    sta vt100.scr_color
    rts 
_colorFor4
    lda vt100.scr_color
    and #$0f 
    and #$6f
    sta vt100.scr_color
    rts 
_colorFor5
    lda vt100.scr_color
    and #$0f 
    and #$af
    sta vt100.scr_color
    rts 
_colorFor6
    lda vt100.scr_color
    and #$3f 
    and #$af
    sta vt100.scr_color
    
    rts
_colorFor7
    lda vt100.scr_color
    and #$3f 
    and #$1f
    sta vt100.scr_color
    rts

styleBack
    cmp #0 
    beq _color0
    cmp #1 
    beq _color1
    cmp #2 
    beq _color2
    cmp #3 
    beq _color3
    cmp #4 
    beq _color4
    cmp #5
    beq _color5
    cmp #6
    beq _color6
    cmp #7
    beq _color7
    rts
_color0
    lda vt100.scr_color
    and #$f0 
    and #$f0
    sta vt100.scr_color
    rts 
_color1
    lda vt100.scr_color
    and #$ff 
    and #$f2
    sta vt100.scr_color
    rts 
_color2
    lda vt100.scr_color
    and #$f0 
    and #$5f
    sta vt100.scr_color
    rts 
_color3
    lda vt100.scr_color
    and #$f0 
    and #$f7
    sta vt100.scr_color
    rts 
_color4
    lda vt100.scr_color
    and #$f0 
    and #$f6
    sta vt100.scr_color
    rts 
_color5
    lda vt100.scr_color
    and #$f0 
    and #$fa
    sta vt100.scr_color
    rts 
_color6
    lda vt100.scr_color
    and #$f0  
    and #$fa
    sta vt100.scr_color
    rts
_color7
    lda vt100.scr_color
    and #$3f 
    and #$f1
    sta vt100.scr_color
    rts
.endsection
.section variables
fisrtSemi 
    .byte $00 
secondSemi 
    .byte $00
thirdSemi 
    .byte $00
value 
    .byte $00
tens 
    .byte 0
    .byte 10
    .byte 20
    .byte 30
    .byte 40
    .byte 50
    .byte 60
    .byte 70
    .byte 80
    .byte 90

ones 
    .byte 0
    .byte 1
    .byte 2
    .byte 3
    .byte 4
    .byte 5
    .byte 6
    .byte 7
    .byte 8
    .byte 9

.endsection
.endnamespace