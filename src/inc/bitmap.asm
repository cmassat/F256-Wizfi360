.section code
;------------------
;input a register
;set the appropiate 
;bitmap pointer
;------------------
setBitmapNumber
    asl a
    tax
    lda mBitmapAttr,x
    sta POINTER_BMP
    inx
    lda mBitmapAttr,x
    sta POINTER_BMP + 1
    rts

;------------------
;input a,x,y register
;a = low
;x = mid
;y = hi
;set address of bitmap
;------------------
setBitmapAddress
    phy 
    ldy #1
    sta (POINTER_BMP), y
    ldy #2
    txa
    sta (POINTER_BMP), y
    ply
    tya
    ldy #3
    sta (POINTER_BMP), y
    rts

setBitmapClut0
    phy
    ldy #0
    lda (POINTER_BMP), y
    and #%0000001
    sta (POINTER_BMP), y
    ply
    rts

etBitmapClut1
    phy
    ldy #0
    lda (POINTER_BMP), y
    and #%0000001
    ora #%0000011
    sta (POINTER_BMP), y
    ply
    rts

etBitmapClut2
    phy
    ldy #0
    lda (POINTER_BMP), y
    and #%0000001
    ora #%0000101
    sta (POINTER_BMP), y
    ply
    rts

etBitmapClut3
    phy
    ldy #0
    lda (POINTER_BMP), y
    and #%0000001
    ora #%0000111
    sta (POINTER_BMP), y
    ply
    rts

showBitmap
    lda #1
    sta (POINTER_BMP)
    rts 

hideAllBitmaps
    lda #0
    sta $D100
    sta $D108
    sta $D110
    rts

.endsection
.section variables
mBitmapAttr
    .word $D100
    .word $D108
    .word $D110
.endsection