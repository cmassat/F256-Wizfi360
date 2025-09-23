rx .namespace
.section code

readResponse
_readLoop
    jsr read_uart_data
    bcs _doneRead
    tax 
    stx tmpChar 
    jsr rollRxBuffer
    ldx tmpChar
    txa 
    jsr vt100.parseChar
    bra _readLoop
    
_doneRead     ; Null-terminate
    rts

read_uart_data
    lda UART_CTRL
    and #CTRL_RX_EMPTY        ; mask for the RX empty bit
    cmp #CTRL_RX_EMPTY        ; loop while buffer is empty
    beq _doneRead
    lda UART_DATA
    clc 
    rts
_doneRead
    sec 
    rts

rollRxBuffer
    ldx tmpChar
    txa
    cmp #13 
    beq _end 
    cmp #10
    beq _end 
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
    ldx tmpChar
    txa 
    sta rxBuffer,y
   ; #pullReg
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

.align 2
tmpChar 
    .word $00
rxBuffer
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00
    .word $00, $00, $00, $00, $00, $00, $00, $00


chkConnect 
    .text 'CONNECT', 0

chkSend
    .text 'SEND', 0
.endsection
.endnamespace