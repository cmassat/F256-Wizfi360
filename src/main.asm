printMsgMacro .macro stringAddress
    pha
    phy
    lda #<\stringAddress
    sta stringPtr
    lda #>\stringAddress
    sta stringPtr+1

    lda #2
    sta MMU_IO_CTRL

    ldy #0
_loop
    lda (stringPtr), y
    cmp #0
    beq _done
    sta  $c000 + 80, y
    iny
    bra _loop
_done
    stz MMU_IO_CTRL
    ply
    pla
.endmacro

*= $2000
; .include "./api/kernel.asm"
; .include "./api/include.asm"
; .include "events.asm"
start
    jmp main
rts
data_addr = $10000
  ; Constants
UART_CTRL  = $DD80   ; UART status/control register
UART_DATA  = $DD81   ; UART TX/RX data register
stringPtr = $a0
MMU_MEM_CTRL = $0000
MMU_IO_CTRL = $0001
CTRL_FAST       =   1
CTRL_RX_EMPTY   =   2
CTRL_TX_EMPTY   =   4
main
    stz MMU_IO_CTRL
;     lda #2
;     sta MMU_IO_CTRL
; _uartLoop

;     lda UART_CTRL
;     sta $c000
;     bra _uartLoop
_handle
    jsr printDebug
    jsr printRx
    lda UART_CTRL
    and #CTRL_TX_EMPTY
    cmp #CTRL_TX_EMPTY
    beq _txData ;buffer emty, so send

_handleRead
    lda UART_CTRL
    and #CTRL_RX_EMPTY       ; Bit 2 = TX ready
    cmp #CTRL_RX_EMPTY
    bne _rxData ;buffer not empty, so read date
    bra _handle
    rts
_txData
    jsr InitUART
    bra _handleRead
    rts
_rxData
    jsr ReadResponse
    bra _handle
    rts

   ; jsr ReadResponse  ; Read until carriage return
    ;jsr printRx
;rts
; Send a single character (in A)
SendChar
    pha
WaitTX
    lda UART_CTRL
    and #CTRL_TX_EMPTY       ; Bit 2 = TX ready
    cmp #CTRL_TX_EMPTY
    bne WaitTX
    pla
    sta UART_DATA
    rts

; Send a null-terminated string pointed to by (stringPtr)
SendString
    ldy #0
NextChar
    lda (stringPtr),y
    beq DoneString
    jsr SendChar
    iny
    bne NextChar         ; Loop until null terminator
DoneString
    rts

; Entry point: Initialize UART and send "AT\r\n"
InitUART
    ; Optionally configure control settings here
    ; (This example assumes UART is pre-initialized by firmware)

    ; Set pointer to "AT\r\n"
    lda #<ATString
    sta stringPtr
    lda #>ATString
    sta stringPtr+1

    jsr SendString
    rts

ReadChar
WaitRX
    lda UART_CTRL
    and #CTRL_RX_EMPTY        ; Bit 0 = RX ready
    cmp #CTRL_RX_EMPTY
    bne _read
    bra WaitRX
_read
    lda UART_DATA         ; Get received byte
    rts

ReadResponse
    ldx #0                ; Buffer index
ReadLoop
    jsr ReadChar
    sta ResponseBuf,x     ; Store byte in buffer
    cmp #10               ; Check for carriage return
    beq DoneRead
    inx
    cpx #ResponseBufLen   ; Avoid overflow
    bne ReadLoop
DoneRead
    inx
    lda #0
    sta ResponseBuf,x     ; Null-terminate
    rts

printRx
    lda #2
    sta MMU_IO_CTRL

    ldy #0
_loop
    lda ResponseBuf, y
    sta $c000 + 160,y
    iny
    cpy #ResponseBufLen
    bne _loop
    stz MMU_IO_CTRL
    rts

printDebug
    #printMsgMacro debugString
    rts

; --- Data ---
RX_RD_COUNT .word       ?
TX_WR_COUNT .word       ?
ATString
    .text "AT",10,13,0     ; "AT\r\n" + null terminator

debugString
    .text "DEBUG",13,10,0     ; "AT\r\n" + null terminator

ResponseBuf
    .fill 64               ; Reserve 64 bytes
ResponseBufLen = 64