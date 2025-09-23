// irq .namespace
// myTimerValue = $ffff
// .section code 
// install
//     stz MMU_IO_CTRL
//     sei 
//     jsr copyROM
//     lda #7
//     sta $08  + 7

//     lda #<irq_handler
//     sta VIRQ

//     lda #>irq_handler
//     sta VIRQ + 1
//     jsr setup
//     cli
    
//     rts

// setup     
//     lda #%11111011 ; keyboard mask
//     sta INT_MASK_0

//     lda #%11011111 ;Via Timer
//     sta INT_MASK_1

//     jsr setupTimer
//     LDA #%11001111     ; Bit 7 = set; bits 0 (CA2), 1 (CA1), 3 (CB2), 4 (CB1)
//     STA $DC0E

//     ;LDA #>myTimerValue
//     ;STA $DC05            ; Writing to T1C-H loads & starts
//     rts 
// setupTimer
//     LDA #$FF
//     STA $DC06
//     LDA #$FF
//     STA $DC07


//     ;LDA $DC0B
//     lda #%01000000       ; Set bit 6 = free-run mode
//     STA $DC0B

//     LDA #$FF
//     STA $DC05        ; T1C_H – writing this starts the timer
//     rts 
// setKeyboard
//     ;set all interupts for via chip
//     LDA #%00000001      ; CA1: falling edge
//     STA $DC0C           ; Set PCR for CA1

//     LDA #%00001010      ; CA2: input, falling edge
//     ORA $DC0C
//     STA $DC0C           ; Set PCR for CA2 too (shared bits)

//     LDA #%10100000      ; CB1: falling edge
//     ORA $DC0C
//     STA $DC0C

//     LDA #%00010000      ; CB2: input, falling edge
//     ORA $DC0C
//     STA $DC0C

//    ; Port B = outputs (driving rows)
//     LDA #%11111111
//     STA $DC02           ; DDRB

//     ; Port A = inputs (reading columns)
//     LDA #%00000000
//     STA $DC03           ; DDRA
//     rts 

// irq_handler
//     ; Save processor state
//     #pushReg
//     php
    
//     lda #2
//     sta MMU_IO_CTRL
//     inc  $C100 + 40
//     lda mKeyPress
//     sta $C100 + 39
//     stz MMU_IO_CTRL

// ; --------------------------
// ; Handle Timer (01) Interrupt
// ; --------------------------
//     lda INT_PEND_1
//     sta mdebug
//     lda mdebug
//     AND #%00100000
//     cmp #%00100000
//     bne _timerEnd

//     LDA $DC0D
//     ;sta mdebug
//     ;lda mdebug
//     AND #%01000000
//     cmp #%01000000
//     bne _timerEnd

//     lda #2
//     sta MMU_IO_CTRL 

//     ;LDA $DC0D
//     ;AND #%01000000
//     inc $C100 + 81

//     inc mTimer
     
//     LDA mdebug
//     STA $C100 + 82
//     stz MMU_IO_CTRL

// _timerEnd

//    lda #%011111111
//    sta $DC0D

//     ;clear interrupts
//     LDA #$FF
//     STA INT_PEND_0

//     LDA #$FF
//     STA INT_PEND_1

//     LDA #$FF
//     STA INT_PEND_2

//     plp
//     #pullReg
//     rti 


// copyROM
//     stz MMU_IO_CTRL

//     lda #7
//     sta $08  + 7

//     lda #$7f
//     sta $08  + 5

// _doLoop
//     #setPointer $A000, SCROLL_SRC_PTR
//     #setPointer $E000, SCROLL_DEST_PTR

//     lda (SCROLL_SRC_PTR)
//     sta (SCROLL_DEST_PTR)

//     jsr _isFinishedCopy
//     bcs _doLoop 

//     lda #$05
//     sta $08  + 5
//     rts 

// _isFinishedCopy
//     lda (SCROLL_DEST_PTR)
//     cmp #$ff 
//     beq _maybe
// _no
//     #add1macro SCROLL_SRC_PTR
//     #add1macro SCROLL_DEST_PTR
//     sec 
//     rts 
// _maybe
//   ;  phy 
//     ldy #1 
//     lda (SCROLL_DEST_PTR), y 
//     cmp #$ff
//    ; ply  
//     beq _yes 
//     bra _no
//     rts 
// _yes 
//     clc
//     rts 


// .endsection 
// .section variables
// tmpMask 
//     .byte $00
// mdebug 
//     .byte $00
// .endsection
// .endnamespace