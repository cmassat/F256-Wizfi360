telnet .namespace
DO   = $FD
DONT = $FE
WILL = $FB
WONT = $FC

STATE_COMMAND = 0 
STATE_OPTION = 1
.section code 

telnetInit 
    stz telnetcmd

    ;lda #telnetBufferRx
    ;clc 
    ;adc #1 
    ;sta TELNET_PTR

    ;sta TELNET_PTR
    ;lda >#telnetBufferRx
    ;sta TELNET_PTR + 1
    rts 


incPtr 
    lda TELNET_PTR
    clc 
    adc #1 
    sta TELNET_PTR

    lda TELNET_PTR + 1 
    adc #0 
    sta TELNET_PTR + 1 
    rts 

handleTelnet
    lda telnetcmd 
    cmp #1 
    beq _end 
    ldy #0
    lda vt100.currChar
    sta telnetBufferRx, y
_read_command 
    jsr read_uart_data
    lda vt100.currChar
    cmp #$FF 
    beq _read_command


    lda vt100.currChar
    sta telnetCommand      
    
    ldy #1
    lda telnetCommand
    sta telnetBufferRx, y
 

_read_option 
    jsr read_uart_data
    lda vt100.currChar 
    cmp telnetCommand
    beq _read_option
    
    lda vt100.currChar
    sta telnetOption
   
    ;sta (TELNET_PTR)
    ;#add1macro TELNET_PTR

    ldy #2
    lda telnetOption
    sta telnetBufferRx, y

    ;ldy #1
    ;lda telnetBufferRx, y
    ;sta telnetCommand

    ;iny 
    ;lda telnetBufferRx, y
    ;sta telnetOption

    
    lda #1 
    sta telnetcmd
;    lda telnetState 
 ;   cmp #STATE_OPTION
 ;   beq _handleOption
 ;   bra handleCommand 
   
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
    ; sta telnetCommand
    ; lda #STATE_OPTION
    ; sta telnetState
    ; jsr sendWillCommand
    ;  stz telnetState
    ; jsr vt100.resetTermState
    rts 
_will 
    ; sta telnetCommand
    ; lda #STATE_OPTION
    ; sta telnetState
    ; jsr sendDoCommand
    ;  stz telnetState
    ; jsr vt100.resetTermState
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

; printBasdfs
;     #pushReg

;     lda #2 
;     sta MMU_IO_CTRL
;     ldy #0 
; _loop 
;     lda telnetBufferRx, y 
;     lsr 
;     lsr 
;     lsr 
;     lsr 
;     tax 
;     lda m_hex, x
;     sta $C000 + (27 * 80),y 
    
;     lda telnetBufferRx, y 
;     and #$0F 
;     tax 
;     lda m_hex, x
;     iny 
;     sta $C000 + (27 * 80),y 
;     iny
;     cpy #40 
;     bne _loop

   
;     lda telnetCommand
;     lsr 
;     lsr 
;     lsr 
;     lsr 
;     tax 
;     lda m_hex, x
;     sta $C000 + (27 * 80) + 45
    
;     lda telnetCommand
;     and #$0F 
;     tax 
;     lda m_hex, x

;     sta $C000 + (27 * 80) + 46

;     lda telnetOption
;     lsr 
;     lsr 
;     lsr 
;     lsr 
;     tax 
;     lda m_hex, x
;     sta $C000 + (27 * 80) + 48
    
;     lda telnetOption
;     and #$0F 
;     tax 
;     lda m_hex, x

;     sta $C000 + (27 * 80) + 49
;     stz MMU_IO_CTRL
;     #pullReg
;     rts 

.endsection
.section variables
telnetcmd 
    .byte $00
willResponse 
    .byte $FF, DO, $03, 0
doResponse
    .byte $FF, WILL, $03, 0

telnetCommand
    .byte $00, $00
telnetOption
    .byte $00, $00


telnetBufferRx 
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
telnetBufferRx_end
.endsection
.endnamespace