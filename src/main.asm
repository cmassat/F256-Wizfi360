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
.dsection code

*= $1000
.dsection variables
.section code
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
TX_BUFFER_PTR = $A0
RX_BUFFER_PTR = TX_BUFFER_PTR + 2
TX_SCREEN_PTR = RX_BUFFER_PTR + 2
RX_SCREEN_PTR = TX_SCREEN_PTR + 2

main
    jsr clearScreen
    stz MMU_IO_CTRL
    stz lineNum
    ;INIT POINTERS
    lda #<$c000
    sta TX_SCREEN_PTR
    lda #>$c000
    sta TX_SCREEN_PTR + 1

    lda screenPos
    sta RX_SCREEN_PTR
    lda screenPos + 1
    sta RX_SCREEN_PTR + 1

_handle
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
  ;  jsr InitUART
    bra _handleRead
    rts
_rxData
    jsr ReadResponse
    bra _handle
    rts

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
_readLoop
    jsr ReadChar
    sta rxBuffer,x    ; Store byte in buffer
    cmp #$D0
    beq _advLine
    cmp #10               ; Check for carriage return
    beq _doneRead
    jsr writeToScreen
    bne _readLoop
_doneRead     ; Null-terminate
    rts
_advLine
    pha
    phx
    inc lineNum
    lda lineNum
    asl
    tax
    lda screenPos, x
    sta RX_SCREEN_PTR
    inx
    lda screenPos, x
    sta RX_SCREEN_PTR + 1
    bra _readLoop
    plx
    pla
    rts

writeToScreen
    cmp #10
    beq _skip
    cmp #13
    beq _skip
    pha
    lda #2
    sta MMU_IO_CTRL
    pla
    sta (RX_SCREEN_PTR)
    #add1macro RX_SCREEN_PTR
    stz MMU_IO_CTRL
_skip
    rts

.include "util.asm"
.endsection
.section variables
; --- Data ---
RX_RD_COUNT .word       ?
TX_WR_COUNT .word       ?
ATString
    .text "AT",10,13,0     ; "AT\r\n" + null terminator

debugString
    .text "DEBUG",13,10,0     ; "AT\r\n" + null terminator

txBufferLen = 80
txBuffer
    .fill txBufferLen               ; Reserve 64 bytes

rxBufferLen = 1840
rxBuffer
    .fill rxBufferLen               ; Reserve 64 bytes

lineNum
    .byte $0
screenPos
    .word $C000
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

.endsection

