; Constants
UART_CTRL  = $DD80   ; UART status/control register
UART_DATA  = $DD81   ; UART TX/RX data register
stringPtr = $a0
MMU_MEM_CTRL = $0000
MMU_IO_CTRL = $0001
CLUT_IO = $0001
CLUT_FOR = $D800
CLUT_BCK = $D840
CLUT_0_ADDR = $D000
CLUT_1_ADDR = $D400
CLUT_2_ADDR = $D800
CLUT_3_ADDR = $DC00
CTRL_FAST       =   1
CTRL_RX_EMPTY   =   2
CTRL_TX_EMPTY   =   4
TX_BUFFER_PTR = $A0
RX_BUFFER_PTR = TX_BUFFER_PTR + 2
TX_SCREEN_PTR = RX_BUFFER_PTR + 2
RX_SCREEN_PTR = TX_SCREEN_PTR + 2
SCREEN_PTR = RX_SCREEN_PTR + 2
TX_SENT_PTR = SCREEN_PTR + 2
SCROLL_SRC_PTR = TX_SENT_PTR + 2
SCROLL_DEST_PTR = SCROLL_SRC_PTR + 2
POINTER_CLUT_SRC = SCROLL_DEST_PTR + 2
POINTER_CLUT_DEST = POINTER_CLUT_SRC + 2
MENU_BUFFER_PTR = POINTER_CLUT_DEST + 2
*= $2000
.dsection code

*= $1000
.dsection variables
.section code
start
    jmp main
    rts
main
    ;jsr clut_default_color
    jsr clut_default_for
    jsr clut_default_bck
    jsr defaultScreenColor
    lda $D001
    ora #%00000100
    sta $D001
    jsr clearScreen
    jsr clearTxBuffer
    stz MMU_IO_CTRL

    ;INIT POINTERS
    lda #<$c000
    sta TX_SCREEN_PTR
    lda #>$c000
    sta TX_SCREEN_PTR + 1

    lda screenPos
    sta SCREEN_PTR
    lda screenPos + 1
    sta SCREEN_PTR + 1

    lda #<txBuffer
    sta TX_BUFFER_PTR
    lda #>txBuffer
    sta TX_BUFFER_PTR + 1

    lda #<txBufferSent
    sta TX_SENT_PTR
    lda #>txBufferSent
    sta TX_SENT_PTR + 1

    stz txReady
    lda #1
    sta mlineNum


    jsr initEvents
    jsr setFrameTimer

    jsr init.wiznet
mainApp
_handle
    ;check Key Strokes
    jsr handleEvents
    lda mKeyPress
    cmp #$88
    beq _menu

    jsr getInput

    lda txReady
    cmp #1
    beq _txData
_handleRead
    jsr _rxData ;buffer not empty, so read date
  ;  bra _handle
    rts
_txData
    jsr sendCommand
    bra _handleRead
    rts
_rxData
    jsr ReadResponse
    bra _handle
    rts
_menu
    stz mKeyPress
    jsr menu.show

    rts
; Send a single character (in A)
getInput
    lda txReady
    cmp #0
    bne _skipKeyPress
    jsr screen.isOkToPrint
    bcs _skipKeyPress
    lda mKeyPress
    cmp #0
    beq _skipKeyPress
    lda mKeyPress
    cmp #8
    beq _backup_buffer
    cmp #13  ;I think this the foenix cr/lf    not sure if #10 does anything
    beq _okToSendTx
    sta (TX_BUFFER_PTR)
     #add1macro TX_BUFFER_PTR
_skipBuffer
    lda mKeyPress
    jsr screen.writeToScreen
    jsr screen.setDebounceTimer
_skipKeyPress
    rts
_backup_buffer
    pha
    lda #0
    sta (TX_BUFFER_PTR)
    lda TX_BUFFER_PTR
    sec
    sbc #1
    sta TX_BUFFER_PTR

    lda TX_BUFFER_PTR + 1
    sbc #0
    sta TX_BUFFER_PTR + 1
    lda #0
    sta (TX_BUFFER_PTR)
    pla
    bra _skipBuffer
    rts
_okToSendTx
    lda #0
    sta (TX_BUFFER_PTR)
    lda #1
    sta  txReady
    jsr _skipBuffer
_end
    rts

sendCommand
    lda #<txBuffer
    sta TX_BUFFER_PTR
    lda #>txBuffer
    sta TX_BUFFER_PTR + 1
    phy
    ldy #0
_loop
    lda txBuffer, y
    cmp #0
    beq _end
    jsr SendChar
    iny
    bra _loop

_end
    lda #13
    jsr sendChar
    lda #10
    jsr sendChar
    ply
    stz txReady
   ; jsr printTxBuffer
  ;  jsr clearTxBuffer
    rts

SendChar
    pha
WaitTX
    lda UART_CTRL
    and #CTRL_TX_EMPTY       ; Bit 2 = TX ready
    cmp #CTRL_TX_EMPTY
    bne WaitTX
    pla
    sta UART_DATA
    lda #13
    rts

ReadResponse
_readLoop
    lda UART_CTRL
    and #CTRL_RX_EMPTY        ; Bit 0 = RX ready
    cmp #CTRL_RX_EMPTY
    beq _doneRead
    lda UART_DATA
   ; jsr rollRxBuffer
    cmp #$FF
    beq _handleTelnet
    jsr screen.writeToScreen
_doneRead     ; Null-terminate

   ; jsr printRxBuffer
    rts
_handleTelnet
    jsr handleTelnet
    rts
handleTelnet
    jsr delay
    lda UART_DATA
    jsr delay
    lda UART_DATA
    rts

rollRxBuffer
    pha
    ldy #0
    ldx #1
_loop
    lda rxBuffer, x
    sta rxBuffer,y
    inx
    iny
    cpy #7
    bne _loop
    pla
    dex
    sta rxBuffer,x
    rts

clearTxBuffer
     pha
    phx
    phy
     ldy #0
_loop
    lda #0
    sta txBuffer, y
    iny
    cpy #10
    bne _loop
    ply
    plx
    pla
    rts

printTxBuffer
    pha
    phx
    phy
    inc counter
    ldy #0
    lda #2
    sta MMU_IO_CTRL
_loop
    lda txbuffer, y
    sta $C000 + (28 * 80),y
    iny
    cpy #80
    bne _loop
    iny
    lda txReady
    clc
    adc #48
    sta $C000 + (28 * 80),y

    iny
    iny
    lda mKeyPress
    lsr
    lsr
    lsr
    lsr
    tax
    lda m_hex,x
    sta $C000 + (28 * 80),y


    iny
    lda mKeyPress
    AND #$0F
    tax
    lda m_hex,x
    sta $C000 + (28 * 80),y

     stz MMU_IO_CTRL

    ply
    plx
    pla
    rts

printRxBuffer
    pha
    phx
    phy
    ldy #0
    lda #2
    sta MMU_IO_CTRL
_loop
    lda rxBuffer, y
    sta $C000 + (27 * 80),y
    iny
    cpy #8
    bne _loop
rts
.include "./inc/kernel.asm"
.include "./inc/keyboard.asm"
.include "util.asm"
.include "events.asm"
.include "screen.asm"
.include "init.asm"
.include "menu.asm"
.include "connect.asm"
.endsection
.section variables
; --- Data ---
RX_RD_COUNT .word       ?
TX_WR_COUNT .word       ?



AT_SINGLE_CONNECTION
    .text "AT+CIPMUX=0",13,10,0     ; "AT\r\n" + null terminator
AT_TRANSPARENT_MODE
    .text "AT+CIPMODE=1",13,10,0     ; "AT\r\n" + null terminator
AT_START_DATA_XFER
    .text "AT+CIPSEND",13,10,0     ; "AT\r\n" + null terminator

m_frames
 .byte $00

m_seconds
    .byte $00

m_hex
    .text '0123456789ABCDEF'

txBuffer
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

txBufferSent
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

rxBuffer
    .byte $00,$00,$00,$00,$00,$00,$00,$00

; rxBufferLen = 1840
; rxBuffer
;     .fill rxBufferLen               ; Reserve 64 bytes
txReady
    .byte $0

counter
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

mlineNum
    .byte $0


.endsection

