;namespace
terminal .namespace
.section code
init 
    rts

handle 
    lda #state.TERMINAL
    jsr state.isState
    bcc _execute 
    rts 
_execute
    jsr exe 
    rts 

exe 
    jsr readKey
    rts 

readKey 
    jsr kbd.getKey
    cmp #0
    beq _end
    cmp #$81
    beq _passThrough
    cmp #$82
    beq _starwars
    jsr tx.sendToBuffer 
    rts 
_end 
    rts 
    
_passThrough
    jsr wizfi.connect_telehack
    bra _waitConnected

_starwars
    jsr wizfi.connect_starwars
    bra _waitConnected
_waitConnected
    jsr rx.readResponse
    lda rx.rxBuffer
    cmp #'T'
    bne _waitConnected

   ;jsr rx.readResponse
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr rx.readResponse  
   ;jsr wizfi.setEchoOff
   jsr rx.readResponse 
   jsr rx.readResponse 
   jsr wizfi.setSingleMode
   jsr rx.readResponse 
    jsr rx.readResponse 
   ; jsr wizfi.setTransMode
   ;jsr rx.readResponse 
   ;jsr rx.readResponse
    jsr wizfi.setTransMode
   jsr rx.readResponse 
   ;jsr rx.readResponse
   ; jsr wizfi.setTransMode
   ;jsr rx.readResponse 
   ;jsr rx.readResponse

  ; jsr wizfi.setPassThruMode
   jsr rx.readResponse 
   jsr rx.readResponse
   jsr wizfi.setPassThruMode
   jsr rx.readResponse 
   jsr rx.readResponse
    rts 

delay 
    ldy #0
_delay 
    iny 
    cpy #0
    bne _delay
    rts 

.endsection
.section variables
.endsection
.endnamespace