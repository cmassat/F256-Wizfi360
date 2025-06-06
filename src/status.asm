status .namespace
.section code
init
    lda #<$D090
    sta STATUS_SCRN_POINTER

    lda #>$D090
    sta STATUS_SCRN_POINTER
    rts

noInternet
    lda #2
    sta MMU_IO_CTRL
    ldx #0
_loop
    lda status_noInternet,x
    sta $D1D0,x
    inx
    cpx #status_noInternet_length
    bne _loop
    stz MMU_IO_CTRL
    rts


.endsection
.section variables
status_noInternet
    .text 'No internet connection found'
status_noInternet_end
status_noInternet_length = status_noInternet_end - status_noInternet
.endsection
.endnamespace