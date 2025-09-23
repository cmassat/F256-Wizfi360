; Constants
UART_CTRL  = $DD80   ; UART status/control register
UART_DATA  = $DD81   ; UART TX/RX data register
stringPtr = $a0


CTRL_FAST       =   1
CTRL_RX_EMPTY   =   2
CTRL_TX_EMPTY   =   4

*= $2000
.dsection code

*= $400
.dsection variables
.section code
start
    jmp main
    rts
main
    jsr screen.set80x30
    jsr clut_default_for
    jsr clut_default_bck
    jsr defaultScreenColor

    jsr tx.init
    jsr wizfi.init
    jsr events.init
    jsr state.init
    jsr vt100.init

_loop
    jsr events.handle
    jsr menu.handle
    jsr terminal.handle
    jsr rx.readResponse
    bra _loop
    rts
debug 
    #pushReg
    lda #2
    sta MMU_IO_CTRL

    lda vt100.esc_buffer
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C000 + 80 * 28

    lda vt100.esc_buffer
    and #$0f
    tay 
    lda m_hex, y
    sta $C001 +  80 * 28

    lda  vt100.esc_buffer + 1
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C003 + 80 * 28

    lda vt100.esc_buffer + 1
    and #$0f
    tay 
    lda m_hex, y
    sta $C004 +  80 * 28


    lda  vt100.esc_buffer + 2
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C006 + 80 * 28

    lda vt100.esc_buffer + 2
    and #$0f
    tay 
    lda m_hex, y
    sta $C007 +  80 * 28
    
    lda  vt100.esc_buffer + 3
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C009 + 80 * 28

    lda vt100.esc_buffer + 3
    and #$0f
    tay 
    lda m_hex, y
    sta $C00a +  80 * 28  



    lda  vt100.esc_buffer + 4
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C00c + 80 * 28

    lda vt100.esc_buffer + 4
    and #$0f
    tay 
    lda m_hex, y
    sta $C00d +  80 * 28  

    lda  vt100.esc_buffer + 5
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C00f + 80 * 28

    lda vt100.esc_buffer + 5
    and #$0f
    tay 
    lda m_hex, y
    sta $C010 +  80 * 28  

    lda  vt100.esc_buffer + 6
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C012 + 80 * 28

    lda vt100.esc_buffer + 6
    and #$0f
    tay 
    lda m_hex, y
    sta $C013 +  80 * 28  

    lda  vt100.esc_buffer + 7
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C015 + 80 * 28

    lda vt100.esc_buffer + 7
    and #$0f
    tay 
    lda m_hex, y
    sta $C016 +  80 * 28  


    lda  vt100.esc_buffer + 8
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C018 + 80 * 28

    lda vt100.esc_buffer + 8
    and #$0f
    tay 
    lda m_hex, y
    sta $C019 +  80 * 28  

    lda  vt100.esc_buffer + 9
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C01b + 80 * 28

    lda vt100.esc_buffer + 9
    and #$0f
    tay 
    lda m_hex, y
    sta $C01c +  80 * 28  


    lda  vt100.esc_buffer + 10
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C01e + 80 * 28

    lda vt100.esc_buffer + 10
    and #$0f
    tay 
    lda m_hex, y
    sta $C01f +  80 * 28  

    lda  vt100.esc_buffer + 11
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C021 + 80 * 28

    lda vt100.esc_buffer + 11
    and #$0f
    tay 
    lda m_hex, y
    sta $C022 +  80 * 28  

    lda  vt100.term_state
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C000 

    lda vt100.term_state
    and #$0f
    tay 
    lda m_hex, y
    sta $C001

    ;col  
    lda  vt100.cursor_col
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C003

    lda vt100.cursor_col
    and #$0f
    tay 
    lda m_hex, y
    sta $C004

    ;row 
    lda  escape_A.digit
    lsr 
    lsr 
    lsr 
    lsr
    tay 
    lda m_hex, y
    sta $C000 +  80 * 27

    lda escape_A.digit
    and #$0f
    tay 
    lda m_hex, y
    sta $C001 +  80 * 27

    stz MMU_IO_CTRL
    #pullReg
    rts 
.include "./inc/F256.asm"
.include "./inc/kernel.asm"

.include "state.asm"
.include "events.asm"
.include "terminal.asm"
.include "keyboard.asm"
.include "menu.asm"
.include "rx.asm"
.include "screen.asm"
.include "tx.asm"
.include "util.asm"
.include "vt100.asm"
.include "wizfi.asm"


.endsection
.section variables
; --- Data ---



mIsInit 
    .word $00

mTimer
    .byte $00


m_seconds
    .word $00





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
    .word  $0

counter
    .word $0



mlineNum
    .word $0


.endsection

; *= $20000
; .include "font.asm"