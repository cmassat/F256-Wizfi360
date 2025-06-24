screen .namespace
DEBOUNCE_VALUE = 2
.section code
setDebounceTimer
    lda #DEBOUNCE_VALUE
    sta m_debounce
    stz mKeyPress
    rts

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

incrementScreenPos
    lda vt100.cursor_col
    cmp #79
    bcs _skip   

    inc vt100.cursor_col
    rts 
_skip   
    stz vt100.cursor_col
    rts
_maxOut
    lda #79
    sta vt100.cursor_col
    rts 
; _nextLine
;     stz vt100.cursor_col
;     lda vt100.cursor_row
;     cmp #24 
;     bcc _nextLineOk
;     jsr scroll_screen
;     rts 
; _nextLineOk
;     inc vt100.cursor_row
;     rts 

carriageReturn
    stz vt100.cursor_col
    rts

lineFeed
    stz vt100.cursor_col
    lda vt100.cursor_row
    cmp #24 
    bcc _nextLineOk
    jsr scroll_screen
    rts 
_nextLineOk
    inc vt100.cursor_row
    rts 
advanceLine
    stz vt100.cursor_col
    lda vt100.cursor_row
    cmp #24 
    bcc _nextLineOk
    jsr scroll_screen
    rts 
_nextLineOk
    inc vt100.cursor_row
    rts 

writeToScreen
    cmp #0
    beq _skip
    cmp #10
    beq _lineFeed
    cmp #13
    beq _carriageReturn
    cmp #8
    beq _bkSpace
    pha
    jsr getScreenPos
    lda #2
    sta MMU_IO_CTRL
    pla
    sta (SCREEN_PTR)
    lda #3
    sta MMU_IO_CTRL
    lda vt100.scr_color
    sta (SCREEN_PTR) 
    ;#add1macro SCREEN_PTR
    jsr incrementScreenPos
_skip
    stz MMU_IO_CTRL
    rts
_lineFeed 
    ;jsr carriageReturn
    jsr lineFeed
    rts
_carriageReturn
    ;jsr linefeed 
    jsr carriageReturn
    rts 
_bkSpace
    jsr bkSpace
    rts

; advanceLine
;     pha
;     phx
;     inc mlineNum
;     lda mlineNum
;     cmp #24
;     beq _reset ; change to scroll
;     lda mlineNum
;     asl
;     tax
;     lda screenPos, x
;     sta SCREEN_PTR
;     inx
;     lda screenPos, x
;     sta SCREEN_PTR + 1
;     plx
;     pla
;     rts
; _reset
;     jsr scroll_screen
;     lda #22
;     sta mlineNum
;     jsr nextLine
;     plx
;     pla
;     rts

bkSpace
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
    CPY #80
    BNE _copyChar
    INX
    CPX #24
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
.endsection

.section variables
;300 ms is 18 frames at 60FPS
m_debounce
    .byte $0


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