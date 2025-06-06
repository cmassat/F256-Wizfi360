.section code

timer_code
    ;lda mSOFSemaphore
    ;eq _skip
    ;stz mSOFSemaphore
    ;jsr startup.handle
    ;jsr terminal.handle
  ;  jsr getKeyStrokes
    ;jsr peekTXBuffer
    ;jsr peekRXBuffer
    ;inc m_ticks

    ;jsr watch_UART_CTRL_TX
    ; jsr watch_UART_CTRL_RX
_skip
    rts

handleEvents
    pha
    phx
    phy
   ; jsr timer_code
_wait_for_event 
    ; Peek at the queue to see if anything is pending
    lda		kernel.args.events.pending  ; Negated count
    bpl		_done

    ; Get the next event.
    jsr		kernel.NextEvent
    bcs		_done

    ; Handle the event
    jsr		_dispatch
_done
    ; Continue until the queue is drained.
  ;  bra		handleEvents
    ply
    plx
    pla
    rts

 _dispatch
   ; Get the event's type
    lda	event.type

   ; Call the appropriate handler
    ; cmp	 #kernel.event.mouse.CLICKS
    ; beq	_mouse_clicked

    cmp #kernel.event.key.PRESSED
    beq keyPressed

    ; cmp #kernel.event.key.RELEASED
    ; beq keyReleased

    ; cmp #kernel.event.timer.EXPIRED
    ; beq handleTimerEvent

    ; cmp	 #kernel.event.mouse.DELTA
    ; beq	_mouse_moved

    rts

handleTimerEvent
    inc mSOFSemaphore
    jsr setFrameTimer
    rts

keyPressed
    lda event.key.ascii
    sta mKeyPress
    inc mKeyRelease
    rts

keyReleased
    pha
    phx
    phy
   ; lda event.key.ascii
   ; sta mKeyRelease
    ply
    plx
    pla
    rts
setFrameTimer
    lda #0
	sta MMU_IO_CTRL
    lda #kernel.args.timer.FRAMES | kernel.args.timer.QUERY
    sta kernel.args.timer.units

    stz kernel.args.timer.absolute
    jsr kernel.Clock.SetTimer

    adc #1
    sta kernel.args.timer.absolute

    lda #kernel.args.timer.FRAMES
    sta kernel.args.timer.units

    jsr kernel.Clock.SetTimer
    rts
    
initEvents

    lda #<event
    sta kernel.args.events+0
    lda #>event
    sta kernel.args.events+1
    rts


.endsection

event	.dstruct	 kernel.event.event_t

.section variables
mSOFSemaphore
    .byte $00
mKeypress
    .byte $00
mKeyRelease
    .byte $00
m_ticks
    .byte $00
mGameSeconds
    .byte $00
evtMouseDx
    .byte $00
evtMouseDy
    .byte $00
evtMouseBtn
    .byte $00
.endsection

