add1macro .macro address
    lda \address
    clc
    adc #1
    sta \address

    lda \address + 1
    clc
    adc #0
    sta \address + 1

.endmacro