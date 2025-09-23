screen .namespace
DEBOUNCE_VALUE = 2
.section code
; setDebounceTimer
;     lda #DEBOUNCE_VALUE
;     sta m_debounce
;    ; stz mKeyPress
;     rts

isOkToPrint
    lda m_debounce
    cmp #$00
    beq _yes
    sec
    rts
_yes
    clc
    rts

nextLine
    pha
    phx
    inc mlineNum
    lda mlineNum
    asl
    tax
    lda screenPos,x
    sta SCREEN_PTR
    inx
    lda screenPos,x
    sta SCREEN_PTR + 1
    plx
    pla
    rts

getScreenPos
    #pushReg

    lda vt100.cursor_row
    asl
    tax 
    lda screenPos,x 
    sta SCREEN_PTR 
    inx 
    lda screenPos,x
    sta SCREEN_PTR + 1 

    lda vt100.cursor_col
    clc 
    adc SCREEN_PTR
    sta SCREEN_PTR

    lda SCREEN_PTR + 1
    adc #0
    sta SCREEN_PTR + 1
    #pullReg 
    rts 

carriageReturn
    stz vt100.cursor_col
    rts
 
lineFeed
    ;stz vt100.cursor_col
    lda vt100.cursor_row
    cmp #24 
    bcc _nextLineOk
    jsr scroll_screen
    rts 
_nextLineOk
    inc vt100.cursor_row
    rts 

as
;x is x coordinate 
;y is y coordinate 
;a is char to print
write2Screen8
    sta char2Print
    
    ;jsr printBuffer
    sty $DE00 
    
    lda #80 ; number of columns 
    sta $DE02
    lda $DE10
    sta SCREEN_PTR
    lda $DE11 
    sta SCREEN_PTR + 1

    lda SCREEN_PTR
    clc 
    adc <#$C000
    sta SCREEN_PTR
    
    lda SCREEN_PTR + 1
    adc >#$C000
    sta SCREEN_PTR + 1

    txa 
    clc 
    adc SCREEN_PTR
    sta SCREEN_PTR
    lda SCREEN_PTR + 1
    adc #$0 
    sta SCREEN_PTR + 1
    adc >#$C000
        
    lda #2 
    sta MMU_IO_CTRL

    ldx char2Print
    txa 
    sta (SCREEN_PTR)
    lda #0
    sta MMU_IO_CTRL
    rts 

bkSpace
    jsr screen.isOkToPrint
    bcs _end
    pha
    lda #2
    sta MMU_IO_CTRL
    lda #$20
    sta (SCREEN_PTR)

    lda SCREEN_PTR
    sec
    sbc #1
    sta SCREEN_PTR

    lda SCREEN_PTR + 1
    sbc #0
    sta SCREEN_PTR + 1

    lda #$20
    sta (SCREEN_PTR)

    stz MMU_IO_CTRL
_bkNotYet
    pla
    ;lda mIsConnected
    ;beq _end 
    lda vt100.cursor_col
    cmp #0
    beq _end
    dec vt100.cursor_col
    jsr screen.DEBOUNCE_VALUE
_end
    rts

; Scroll up: move lines 1–23 into lines 0–22
scroll_screen
    pha
    phx
    phy
    lda #<$c000 + 80
    sta SCROLL_SRC_PTR
    lda #>$c000 + 80
    sta SCROLL_SRC_PTR + 1

    lda #<$c000
    sta SCROLL_DEST_PTR
    lda #>$c000
    sta SCROLL_DEST_PTR + 1

    lda #2
    sta MMU_IO_CTRL

    LDX #0                  ; Y = source line index
_moveRow
    LDY #0              ; X = column
_copyChar
    lda #2
    sta MMU_IO_CTRL
    LDA (SCROLL_SRC_PTR)    ; Load from next line
    STA (SCROLL_DEST_PTR)     ; Store into current line

    lda #3 
    sta MMU_IO_CTRL
    LDA (SCROLL_SRC_PTR)    ; Load from next line
    STA (SCROLL_DEST_PTR)     ; Store into current line
    #add1macro SCROLL_SRC_PTR
    #add1macro SCROLL_DEST_PTR
    INY
    CPY #85
    BNE _copyChar
    INX
    CPX #23
    BNE _moveRow


    lda #2
    sta MMU_IO_CTRL
    lda SCROLL_SRC_PTR
    sec 
    sbc #80
    sta SCROLL_SRC_PTR

    lda SCROLL_SRC_PTR + 1
    sbc #0 
    sta SCROLL_SRC_PTR + 1
    ldy #0 
_clearLine
    lda #$20
    sta (SCROLL_SRC_PTR)
    #add1macro SCROLL_SRC_PTR
    iny 
    cpy #80 
    bne _clearLine
    
    stz MMU_IO_CTRL
    ply
    plx
    pla
    rts

clearScreen
    lda <#$C000
    sta SCROLL_DEST_PTR
    lda >#$C000
    sta SCROLL_DEST_PTR + 1
    lda #2
    sta MMU_IO_CTRL

    ldx #0 
_loopRow 
    ldy #0
_loopChar
    lda #$20
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny 
    cpy #80 
    bcc _loopChar
    inx 
    cpx #26
    bcc _loopRow
         
    stz MMU_IO_CTRL

    rts


set80x30
    stz MMU_IO_CTRL
     lda #1
    sta $D000

    ;Double Font
    lda $D001
    ora #%00000100
    sta $D001
    rts 
.endsection

.section variables
;300 ms is 18 frames at 60FPS
m_debounce
    .byte $0

char2Print
    .byte $00 

screenPos
    .word $c000
    .word $C050
    .word $C0A0
    .word $C0F0
    .word $C140
    .word $C190
    .word $C1E0
    .word $C230
    .word $C280
    .word $C2D0
    .word $C320
    .word $C370
    .word $C3C0
    .word $C410
    .word $C460
    .word $C4B0
    .word $C500
    .word $C550
    .word $C5A0
    .word $C5F0
    .word $C640
    .word $C690
    .word $C6E0
    .word $C730
    .word $C780
.endsection
.endnamespace