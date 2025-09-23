;Erase Line
escape_K .namespace
ESC_CHAR='K'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    lda vt100.esc_buffer + 2 
    cmp #'K'
    beq _erase2End
    ;cmp #'1'
    ;beq _erase2Start
    ;cmp #'2'
    ;beq _eraseLine
    
    sec
    rts
_erase2End
    jsr erase2End
    rts 
_eraseLine
    jsr eraseLine 
    rts 
_erase2Start
    jsr erase2Start
    rts 
eraseLine 
    jsr erase2End
    jsr erase2Start
    rts    

erase2End
    jsr screen.getScreenPos
    ldy vt100.cursor_col
_loop 
    cpy #80
    bcs _end
    
    lda #2
    sta MMU_IO_CTRL
    lda #$20
    sta (SCREEN_PTR),y 
    lda #3
    sta MMU_IO_CTRL
    lda #$50
    sta (SCREEN_PTR),y 
    iny
    bra _loop 
_end 
    stz MMU_IO_CTRL
    clc
    rts 

erase2Start
    jsr screen.getScreenPos
    ldy vt100.cursor_col
_loop 
    cpy #0
    bcs _end
    
    lda #2
    sta MMU_IO_CTRL
    lda #$20
    sta (SCREEN_PTR),y 
    lda #3
    sta MMU_IO_CTRL
    lda #$50
    sta (SCREEN_PTR),y 
    dey
    bra _loop 
_end 
    stz MMU_IO_CTRL
    clc
    rts 

.endsection
.section  variables
value 
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