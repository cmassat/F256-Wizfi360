.section code
handleEvents
    
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
    rts

 _dispatch

    lda	event.type

    cmp #kernel.event.key.PRESSED
    beq keyPressed

    cmp #kernel.event.key.RELEASED
    beq keyReleased

    cmp #kernel.event.timer.EXPIRED
    beq handleTimerEvent

    rts

handleTimerEvent
    jsr setFrameTimer
    ;#add1macro m_frames

    lda screen.m_debounce
    cmp #0
    beq _skip_debounce
    dec screen.m_debounce
_skip_debounce
    lda mKeyPress
    cmp #0
    beq _skip
    lda mKeyPress
    cmp mKeyRelease
    bne _skip
   ; jsr getInput
_skip
    rts

keyPressed
    lda event.key.ascii
    sta mKeyPress
_skip
    rts

keyReleased
    lda event.key.ascii
    stz mKeyPress
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

    stz mKeyPress
    stz mKeyRelease
    rts
.endsection

event	.dstruct	 kernel.event.event_t

.section variables
mSOFSemaphore
    .word $00
mKeypress
    .word $00
mKeyStatus
    .word $00
mKeyRelease
    .word $00
m_ticks
    .word $00
mGameSeconds
    .word $00
evtMouseDx
    .word $00
evtMouseDy
    .word $00
evtMouseBtn
    .word $00
.endsection

