
.section code 
clearVideo
    lda #0
    sta VCKY_CTRL
    sta VCKY_CTRL_ATTRIB
    sta mVideoCtrl
    rts

enableText
    lda mVideoCtrl
    ora #%00000011
    sta mVideoCtrl
    rts

enableSprite
    lda mVideoCtrl
    ora #%00100000
    sta mVideoCtrl
    rts

enableTile
    lda mVideoCtrl
    ora #%00010000
    sta mVideoCtrl
    rts

enableBitmap
    lda mVideoCtrl
    ora #%00001000
    sta mVideoCtrl
    rts

enableGrafix
    lda mVideoCtrl
    ora #%0000100
    sta mVideoCtrl
    rts

enableTextOverlay
    lda mVideoCtrl
    ora #%00000011
    sta mVideoCtrl
    rts

setVideo
    lda mVideoCtrl
    sta VCKY_CTRL
    rts


clearLayers
    lda #0
    sta VCKY_LAYER_01_00_CTRL
    sta VCKY_LAYER_02_CTRL
    sta mVideoLayerCtrl01
    sta mVideoLayerCtrl_2
    rts

enableBitmapLayer0
    lda mVideoLayerCtrl01
    and #$f0
    ora #$00
    sta mVideoLayerCtrl01
    rts 

enableBitmapLayer1
    lda mVideoLayerCtrl01
    and #$0f
    ora #$10
    sta mVideoLayerCtrl01
    rts

enableBitmapLayer2
    lda #$02
    sta mVideoLayerCtrl_2
    rts 

setTileMapLayer0
    lda mVideoLayerCtrl01
    and #$F0
    ora #$04
    sta mVideoLayerCtrl01
    rts

setTileMapLayer1
    lda mVideoLayerCtrl01
    and #$0F
    ora #$50
    sta mVideoLayerCtrl01
    rts

setTileMapLayer2
    lda #$06
    sta mVideoLayerCtrl_2
    rts    


setDoubleText
    lda #%00000110
    sta VCKY_CTRL_ATTRIB
    rts

setLayers
    lda mVideoLayerCtrl01
    sta VCKY_LAYER_01_00_CTRL
    
    lda mVideoLayerCtrl_2
    sta VCKY_LAYER_02_CTRL
    rts

;a = red
;x = green
;y = blue
setBackgroundColor
    lda #$7c
    sta VKY_BKG_COL_R
    txa
    sta VKY_BKG_COL_G
    tya
    sta VKY_BKG_COL_B
    rts

clearScreenMemory
    pha
    phx
    phy
    lda #2
    sta MMU_IO_CTRL
    lda #' '
    ldy #0
_loop
    sta $C000, y
    sta $C000 + $ff, y
    sta $C000 + $ff + $ff , y
    sta $C000 + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff, y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff,  y
    sta $C000 + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $ff + $80,  y
    iny
    cpy #0
    bne _loop
    stz MMU_IO_CTRL 
    ply
    plx
    pla
    rts
.endsection

.section variables
mVideoCtrl
    .byte $00

mVideoLayerCtrl01
    .byte $00
mVideoLayerCtrl_2
    .byte $00
.endsection