; R0 = 12
MOV R0, 0b1100
; R1 = 10
MOV R1, 0b1010
; R3 = -16
MOV R3, 0xFFF0
; R4 = 2
MOV R4, 2

; 12 + 10 = 22
ADD R2, R0, R1
STR R2, 110

; 12 - 10 = 2
SUB R2, R0, R1
STR R2, 110

; -(12) = -12 = -0b0000000000001100 = 0b1111 1111 1111 0100 = 0xFFF4
NEG R2, R0
STR R2, 110

; 12 + 1 = 13 = 0x000D
INC R2, R0
STR R2, 110

; 12 - 1 = 11 = 0x000B
DEC R2, R0
STR R2, 110

; 0b1100 & 0b1010 = 0b1000 = 0x0008
AND R2, R0, R1
STR R2, 110

; 0b1100 | 0b1010 = 0b1110 = 0x000E
OR R2, R0, R1
STR R2, 110

; 0b1100 ^ 0b1010 = 0b0110 = 0x0006
XOR R2, R0, R1
STR R2, 110

; ~(0b1100) = 0xFFF3
NOT R2, R0
STR R2, 110

; 0xFFF0 >> 2 (Arithmetic) = 0b1011 1111 1111 1100 = 0xBFFC
ASR R2, R3, R4
STR R2, 110

; 0xFFF0 << 2 = 0b1111 1111 1100 0000 = 0xFFC0
ASL R2, R3, R4
STR R2, 110

; 0xFFF0 >> 2 (Logical) = 0b0011 1111 1111 1100 = 0x3FFC
LSR R2, R3, R4
STR R2, 110

; 0xFFF0 << 2 = 0b1111 1111 1100 0000 = 0xFFC0
LSL R2, R3, R4
STR R2, 110

; 0xFFF0 csr 2 = 0b0011 1111 1111 1100 = 0x3FFC
CSR R2, R3, R4
STR R2, 110

; 0xFFF0 csl 2 = 0b1111 1111 1100 0011 = 0xFFC3
CSL R2, R3, R4
STR R2, 110