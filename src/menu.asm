menu .namespace
.section code
handle 
    lda #state.MENU
    jsr state.isState 
    bcc _exec 
    rts 
_exec 
    jsr show
    rts 

show
    #pushReg
_wait 
     jsr rx.readResponse

    jsr clearScreen
    jsr printMenu
    jsr printStatusBar
    ;jsr setDebounce

    jsr kbd.is_1_pressed
    bcc _setTerminalMode 

    #pullReg
    rts
_setTerminalMode
    lda #state.TERMINAL
    jsr state.set
     #pullReg
    rts 

printMenu
    lda <#m_option_00
    sta SCROLL_SRC_PTR
    lda >#m_option_00
    sta  SCROLL_SRC_PTR + 1

    lda <#$C000 + (80 * 1) + 27
    sta SCROLL_DEST_PTR
    lda >#$C000 + (80 * 1) + 27
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
    lda <#$C000 + (81 * 2) + 25
    sta SCROLL_DEST_PTR
    lda >#$C000 + (81 * 2) + 25
    sta  SCROLL_DEST_PTR + 1
    #add1macro SCROLL_SRC_PTR
    bra _loop
    rts
.endsection 

printStatus 
     #pushReg
    lda <#$C000 + (80 * 29) + 10
    sta SCROLL_DEST_PTR
    lda >#$C000 + (80 * 29) + 10
    sta  SCROLL_DEST_PTR + 1

    lda #2 
    sta MMU_IO_CTRL
    lda $D659 
    sta (SCROLL_DEST_PTR)
    lda #0 
    sta MMU_IO_CTRL
    #pullReg
    rts 

printStatusBar 
    #pushReg
    lda <#$C000 + (80 * 26)
    sta SCROLL_DEST_PTR
    lda >#$C000 + (80 * 26)
    sta  SCROLL_DEST_PTR + 1

    lda #3 
    sta MMU_IO_CTRL

    ldy #0 
_loop 
    lda #$55
    sta (SCROLL_DEST_PTR)
    #add1macro SCROLL_DEST_PTR
    iny
    cpy #80
    bcc _loop
    lda #0 
    sta MMU_IO_CTRL
    #pullReg
    rts 

.section variables 
m_option_00
    .text '01 - Enter Terminal Mode',10
    .text '02 - Connect To Address',10
    .byte $0
.endsection 
.endnamespace