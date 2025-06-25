; Constants
UART_CTRL  = $DD80   ; UART status/control register
UART_DATA  = $DD81   ; UART TX/RX data register
stringPtr = $a0


CTRL_FAST       =   1
CTRL_RX_EMPTY   =   2
CTRL_TX_EMPTY   =   4

*= $2000
.dsection code

*= $1000
.dsection variables
.section code
start
    jmp main
    rts
main
    stz mIsInit
    stz mIsConnected 
    jsr wiz.initWiz
    ;jsr clut_default_color
    jsr clut_default_for
    jsr clut_default_bck
    jsr defaultScreenColor
    lda $D001
    ora #%00000100
    sta $D001
    jsr clearScreen
    jsr app.clearTxBuffer
    stz MMU_IO_CTRL

    jsr vt100.init

    ;INIT POINTERS
    lda #<$c000
    sta TX_SCREEN_PTR
    lda #>$c000
    sta TX_SCREEN_PTR + 1


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
    jsr app.mainApp
   ; jsr menu.show
    rts

printTxBuffer
    #pushReg
    ldy #0
    lda #2
    sta MMU_IO_CTRL
_loop
    lda vt100.esc_buffer, y
    sta $C000 + (28 * 80),y
    iny
    cpy #32
    bne _loop
    
    
    lda vt100.cursor_col
    lsr 
    lsr 
    lsr 
    lsr 
    tax 
    lda m_hex,x
    sta $C000 + (27 * 80)


    lda vt100.cursor_col
    and #$0F 
    tax
    lda m_hex,x
    sta $C000 + (27 * 80) + 1

    lda tmpKey
    lsr 
    lsr 
    lsr 
    lsr 
    tax 
    lda m_hex,x
    sta $C000 + (27 * 80) + 3


    lda tmpKey
    and #$0F 
    tax
    lda m_hex,x
    sta $C000 + (27 * 80) + 4
    stz MMU_IO_CTRL

    #pullReg
    rts

; printRxBuffer
;     pha
;     phx
;     phy
;     ldy #0
;     lda #2
;     sta MMU_IO_CTRL
; _loop
;     lda rxBuffer, y
;     sta $C000 + (27 * 80),y
;     iny
;     cpy #8
;     bne _loop
; rts
.include "./inc/kernel.asm"
.include "./inc/keyboard.asm"
.include "util.asm"
.include "events.asm"
.include "screen.asm"
.include "init.asm"
.include "menu.asm"
.include "connect.asm"
.include "vt100.asm"
.include "app.asm"
.include "telnet.asm"
.include "./inc/video.asm"
.include "./inc/F256.asm"
.include "./inc/bitmap.asm"
.include "wiznetResponse.asm"
.endsection
.section variables
; --- Data ---

tmpKey
    .byte $00


mIsInit 
    .byte $00
mIsConnected 
    .byte $00
AT_SINGLE_CONNECTION
    .text "AT+CIPMUX=0",13,10,0     ; "AT\r\n" + null terminator
AT_TRANSPARENT_MODE
    .text "AT+CIPMODE=1",13,10,0     ; "AT\r\n" + null terminator
AT_START_DATA_XFER
    .text "AT+CIPSEND",13,10,0     ; "AT\r\n" + null terminator

; m_frames
;  .byte $00

m_seconds
    .byte $00



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



mlineNum
    .byte $0


.endsection

; *= $20000
; .include "font.asm"