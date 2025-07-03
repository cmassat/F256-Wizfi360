;hide show cursor
escape__n .namespace
ESC_CHAR='n'
MAX_LENGTH = 80
.section code 
handle
    lda vt100.currChar
    cmp #ESC_CHAR
    beq _parse
    sec 
    rts 
_parse
    lda vt100.esc_buffer + 2
    cmp #'6'
    bne _skip 
    lda vt100.esc_buffer + 3
    cmp #'n'
    beq _sendRowCol
_skip
    clc 
    rts 
_sendRowCol
    lda #<txBuffer
    sta TX_POINTER
    lda #>txBuffer
    sta TX_POINTER + 1
    lda #ESC
    sta (TX_POINTER)
    #add1macro TX_POINTER
    lda #"["
    sta (TX_POINTER)
    jsr getRow
    #add1macro TX_POINTER
    lda #';'
    sta (TX_POINTER)
    jsr getCol 
    #add1macro TX_POINTER
    lda #'R'
    sta (TX_POINTER)
    jsr app.sendCommand
    clc
    rts

getRow
    #add1macro TX_POINTER
    lda vt100.cursor_row
    cmp #$A 
    bcc _ones
    bcs _tens
    clc
    rts 
_ones
    jsr _doDigit0
    rts
_tens
    #add1macro TX_POINTER
    lda vt100.cursor_row
    lsr 
    lsr 
    lsr 
    lsr 
    jsr _doDigit0
    #add1macro TX_POINTER
    lda vt100.cursor_row
    jsr _doDigit1
    rts 
_doDigit0
    and #$0f 
    adc #'0'
    sta (TX_POINTER)
    sta row
    rts 
_doDigit1
    and #$0f 
    adc #'0'
    sta (TX_POINTER)
    sta row + 1
    rts 

getCol 
    lda vt100.cursor_col 
    cmp #$A 
    bcc _ones 
    bcs _tens
    rts 
_ones 
    #add1macro TX_POINTER
    lda vt100.cursor_col  
    jsr _doDigit0
    rts 
_tens
    #add1macro TX_POINTER
    lda vt100.cursor_col
    lsr 
    lsr 
    lsr 
    lsr 
    jsr _doDigit0
    #add1macro TX_POINTER
    lda vt100.cursor_col
    jsr _doDigit1
    rts 
_doDigit0
    and #$0f 
    adc #'0'
    sta (TX_POINTER)
    sta col 
    rts 
_doDigit1
    and #$0f 
    adc #'0'
    sta col + 1
    sta (TX_POINTER)
    rts 
.endsection
.section  variables
row  
    .byte $00, $00

col 
    .byte $00, $00
.endsection
.endnamespace