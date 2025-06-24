DO   = $FD
DONT = $FE
WILL = $FB
WONT = $FC

STATE_COMMAND = 0 
STATE_OPTION = 1
.section code 
handleTelnet
    
    jsr read_uart_data
    bcs _end 
    sta telnetCommand 
    lda telnetState 
    cmp #STATE_OPTION
    beq _handleOption
    bra handleCommand 
_end 
    rts 
_handleOption
    jsr handleOption
    rts 

handleCommand
    lda telnetCommand
    cmp #DO
    beq _do
    cmp #WILL
    beq _will 
_end  
   
    rts
_do
    sta telnetCommand
    lda #STATE_OPTION
    sta telnetState
    jsr sendWillCommand
     stz telnetState
    jsr vt100.resetTermState
    rts 
_will 
    sta telnetCommand
    lda #STATE_OPTION
    sta telnetState
    jsr sendDoCommand
     stz telnetState
    jsr vt100.resetTermState
    rts 



handleOption
    jsr read_uart_data
    bcs _end 
    lda telnetCommand
    cmp #WILL
    beq _will 
    cmp #DO
    beq _do
_end
    rts 
_will
    jsr sendDoCommand
    rts 
_do 
    jsr sendWillCommand
    rts 

sendWillCommand
    phy
    ldy #0
_loop
    lda willResponse, y 
    cmp #0
    beq _end
    jsr app.SendChar
    iny
    bra _loop

_end
    ply
    stz txReady
    rts

sendDoCommand
    phy
    ldy #0
_loop
    lda doResponse, y
    cmp #0
    beq _end
    jsr app.SendChar
    iny
    bra _loop

_end

    ply
    stz txReady
    rts

.endsection
.section variables
willResponse 
    .byte $FF, DO, $03, 0
doResponse
    .byte $FF, WILL, $03, 0

telnetOption
    .byte $0
telnetState 
    .byte $0
telnetCommand
    .byte $00

.endsection