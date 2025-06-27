rx .namespace
.section code
readResponse
_readLoop
    jsr read_uart_data
    bcs _doneRead
    sta tmpChar 
    lda tmpChar
    jsr rollRxBuffer
    lda tmpChar
    jsr vt100.parseChar
_doneRead     ; Null-terminate
    rts

rollRxBuffer
    lda connect.m_isConnected
    cmp #1 
    beq _end
    lda tmpChar
    cmp #13 
    beq _end 
    cmp #10
    beq _end 
    #pushReg
    ldy #0
    ldx #1
_loop
    lda rxBuffer, x
    sta rxBuffer,y
    inx
    iny
    cpy #7
    bne _loop
    dey
    lda tmpChar 
    sta rxBuffer,y
    #pullReg
_end
    rts


isConnect
    ldy #0 
_loop
    lda chkConnect, y
    cmp #0
    beq _yes  
    lda chkConnect, y
    cmp rxBuffer, y 
    bne _no 
    iny 
    bra _loop
    rts 
_no 
    sec 
    rts
_yes 
    clc 
    rts 

isCipSend
    ldy #0 
_loop
    lda chkSend, y
    beq _yes  
    lda chkSend, y
    cmp rxBuffer, y 
    bne _no 
    iny 
    bra _loop
    rts 
_no 
    sec 
    rts
_yes 
    clc 
    rts 

.endsection  
.section variables
tmpChar 
    .byte $00
rxBuffer
    .byte $00, $00, $00, $00, $00, $00, $00, $00

chkConnect 
    .text 'CONNECT', 0

chkSend
    .text 'SEND', 0
.endsection
.endnamespace