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

writeToScreen
    cmp #0
    beq _skip
    cmp #10
    beq _skip
    cmp #13
    beq _advLine
    cmp #8
    beq _bkSpace
    pha
    lda #2
    sta MMU_IO_CTRL
    pla
    sta (SCREEN_PTR)
    lda #3
    sta MMU_IO_CTRL
    lda vt100.scr_color
    sta (SCREEN_PTR) 
    #add1macro SCREEN_PTR
_skip
    stz MMU_IO_CTRL
    rts
_advLine
    jsr advanceLine
    rts
_bkSpace
    jsr bkSpace
    rts
advanceLine
    pha
    phx
    inc mlineNum
    lda mlineNum
    cmp #24
    beq _reset ; change to scroll
    lda mlineNum
    asl
    tax
    lda screenPos, x
    sta SCREEN_PTR
    inx
    lda screenPos, x
    sta SCREEN_PTR + 1
    plx
    pla
    rts
_reset
    jsr scroll_screen
    lda #22
    sta mlineNum
    jsr nextLine
    plx
    pla
    rts

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
.endsection
.endnamespace