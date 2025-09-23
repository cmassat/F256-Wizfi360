; --- Telnet constants ---
IAC  = $FF
SE   = $F0   ; end subneg
SB   = $FA   ; start subneg
WILL = $FB
WONT = $FC
DO   = $FD
DONT = $FE

; External:
;   NextByte: returns C=0, A=byte  OR  C=1 if no input
;   PutByte : outputs A (optional, shown in usage)

; FilterNext:
;   Strips Telnet IAC sequences, returns only data bytes.
;   On return: C=0 -> A = data byte;  C=1 -> no data available.
FilterNext:
FN_Loop:
    JSR NextByte
    BCS FN_NoInput             ; nothing available

    CMP #IAC
    BNE FN_EmitData            ; normal data byte -> return it

    ; Saw IAC, read command byte
    JSR NextByte
    BCS FN_NoInput             ; incomplete

    CMP #IAC
    BEQ FN_EmitFF              ; IAC IAC => literal $FF

    ; Negotiation 3-byte: WILL/WONT/DO/DONT <opt>
    CMP #WILL
    BEQ FN_SkipOpt
    CMP #WONT
    BEQ FN_SkipOpt
    CMP #DO
    BEQ FN_SkipOpt
    CMP #DONT
    BEQ FN_SkipOpt

    ; Subnegotiation: IAC SB <opt> ... IAC SE
    CMP #SB
    BEQ FN_SkipSB

    ; Single-byte IAC command -> ignore and continue
    JMP FN_Loop

FN_SkipOpt:
    JSR NextByte               ; eat <opt>
    BCS FN_NoInput
    JMP FN_Loop

FN_SkipSB:
    ; At: IAC SB <opt> ...
    JSR NextByte               ; eat <opt>
    BCS FN_NoInput

FN_SB_Loop:
    JSR NextByte
    BCS FN_NoInput

    CMP #IAC
    BNE FN_SB_Loop             ; keep skipping inside SB

    ; Saw IAC inside SB
    JSR NextByte
    BCS FN_NoInput

    CMP #IAC
    BEQ FN_SB_Loop             ; IAC IAC -> escaped $FF, continue skipping

    CMP #SE
    BEQ FN_Loop                ; IAC SE ends SB -> resume normal

    JMP FN_SB_Loop             ; other IAC <x> inside SB -> ignore

FN_EmitFF:
    LDA #$FF
FN_EmitData:
    CLC                        ; data byte ready
    RTS

FN_NoInput:
    SEC                        ; no byte available
    RTS