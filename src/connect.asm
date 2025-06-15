connect .namespace
.section code 
show
    lda #<m_address
    sta MENU_BUFFER_PTR
    lda #>m_address
    sta MENU_BUFFER_PTR + 1
    jsr clearScreen
    jsr printAddressPrompt
    ;jsr getAddress
    rts

printAddressPrompt
    lda <#m_label_address
    sta SCROLL_SRC_PTR
    lda >#m_label_address
    sta SCROLL_SRC_PTR + 1

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

; getAddress
;     jsr screen.isOkToPrint
;     bcs _skipKeyPress
;     lda mKeyPress
;     cmp #0
;     beq _skipKeyPress
;     lda mKeyPress
;     cmp #8
;     beq _backup_buffer
;     cmp #13  ;I think this the foenix cr/lf    not sure if #10 does anything
;     beq _okToSendTx
;     sta (MENU_BUFFER_PTR)
;     sta (SCROLL_DEST_PTR)
;     #add1macro MENU_BUFFER_PTR
;     #add1macro SCROLL_DEST_PTR
; _skipBuffer
;     lda mKeyPress
;     jsr screen.writeToScreen
;     jsr screen.setDebounceTimer
; _skipKeyPress
;     rts
; _backup_buffer
;     pha
;     lda #0
;     sta (TX_BUFFER_PTR)
;     lda TX_BUFFER_PTR
;     sec
;     sbc #1
;     sta TX_BUFFER_PTR

;     lda TX_BUFFER_PTR + 1
;     sbc #0
;     sta TX_BUFFER_PTR + 1
;     lda #0
;     sta (TX_BUFFER_PTR)
;     pla
;     bra _skipBuffer
;     rts
; _okToSendTx
;     lda #0
;     sta (TX_BUFFER_PTR)
;     lda #1
;     sta  txReady
;     jsr _skipBuffer
; _end
;     rts




.endsection 

.section variables 
.endsection
m_address
    .fill 80
m_port
    .word $00

m_label_address
    .text 'Enter Address: "www.somebbs.org" then hit enter',10
    .text '?',0

m_label_port
    .text '',0
.endnamespace