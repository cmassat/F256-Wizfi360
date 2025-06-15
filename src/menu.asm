menu .namespace
.section code
show
    jsr clearScreen
    jsr printMenu

_loop
    jsr handleEvents
    lda mKeyPress
    cmp #49
    beq _terminal
    cmp #50
    beq _connect
    bra _loop
    rts
_terminal
    stz mKeyPress
    jsr clearScreen
    jsr init.screen
    jsr mainApp
    rts
_connect
    jsr connect.show
    rts
printMenu
    lda <#m_option_00
    sta SCROLL_SRC_PTR
    lda >#m_option_00
    sta  SCROLL_SRC_PTR + 1

    lda <#$C000
    sta SCROLL_DEST_PTR
    lda >#$C000
    sta  SCROLL_DEST_PTR + 1
    lda #2
    sta MMU_IO_CTRL

    ldx #0
_loop
    lda (SCROLL_SRC_PTR)
    cmp #0
    beq _done
    cmp #10
    beq _nextLine
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_SRC_PTR
    #add1macro SCROLL_DEST_PTR
    bra _loop
_done
    stz MMU_IO_CTRL
    rts
_nextLine
    inx
    inx
    lda screenPos,x
    sta SCROLL_DEST_PTR
    inx
    lda screenPos,x
    sta SCROLL_DEST_PTR + 1
    dex
    #add1macro SCROLL_SRC_PTR
    bra _loop
    rts
.endsection 

.section variables 
m_option_00
    .text '01 - Enter Terminal Mode',10
    .text '02 - Connect To Address',10
    .byte $0
.endsection 
.endnamespace