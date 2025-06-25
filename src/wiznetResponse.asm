wiz .namespace
.section code
CR = $0D
LF = $0A
initWiz
    stz index
    lda #0
    sta buffer 
    sta buffer + 1
    sta buffer + 2 
    sta buffer + 3 
    sta buffer + 4 
    sta buffer + 5
    rts 

readResponse
    
_readLoop
    jsr read_uart_data
    bcs _doneRead
    jsr checkATResponse
    bcs _doneRead
    jsr vt100.parseChar
_doneRead     ; Null-terminate
    rts

checkATResponse
    sta tmpChar
    lda index
    beq _checkCR
    bne _checkRest
_checkCR  
    lda tmpChar
    cmp #$0D
    beq _yes
    stz index
    clc 
    rts 
_yes 
    lda tmpChar
    sta buffer 
    inc index
   
    sec
    rts
_checkRest 

    jsr checkFirstLetter
    rts 


checkFirstLetter
    lda index 
    cmp #1 
    beq _checkLineFeed 
    cmp #2 
    beq _checkLetter
    
    lda buffer + 2 
    cmp #'r'
    beq _checkReady
    jsr sendChars
    rts 
_checkLineFeed
    ldx index 
    lda tmpChar 
    sta buffer, x 
    
    inc index
    cmp #LF 
    bne _noMatch
    sec  
    rts 
_checkLetter
    ldx index 
    lda tmpChar
    sta buffer, x
   
    inc index
   ; lda tmpChar 
   ; cmp #'O'
   ; beq _checkOK 
   ; jsr sendChars
    sec 
    rts 
_checkReady 
    jsr checkReady
    rts 
_noMatch
    jsr sendChars
    sec 
    rts

checkReady
    ldx index 
    lda tmpChar
    sta buffer, x
   
    lda tmpChar
    cmp chkReady,x 
    bne _notMatched
    jsr print
    inc index
    lda index 
    cmp #9
    beq _matched
    sec 
    rts 
_notMatched
    jsr sendChars
    sec
    rts
_matched 
    stz index
    sec
    rts 

sendChars
    ldy #0 
_sendChars 
    lda buffer,y  
    jsr vt100.parseChar
    iny 
    cpy index 
    bcc _sendChars
    beq _sendChars
    jsr initWiz
    sec
    rts


print 
    lda #2 
    sta MMU_IO_CTRL
    ldy  #0 
_loop 
    lda buffer, y 
    sta $c000 + (80 * 27),y 
    iny 
    cpy #9
    bne _loop 
    stz MMU_IO_CTRL
    rts 
.endsection 
.section variables
.endsection

chkReady
    .text CR, LF, 'ready' ,CR, LF


tmpChar 
    .byte $00
index
    .byte $00
buffer 
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00

.endnamespace