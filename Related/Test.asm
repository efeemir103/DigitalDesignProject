; H
MOV R0, 0b0100100011101000
STR R1, 0x0

; e
MOV R0, 0b0110010111101000
STR R1, 0x1

; l
MOV R0, 0b0110110011101000
STR R1, 0x2

; l
MOV R0, 0b0110110011101000
STR R1, 0x3

; o
MOV R0, 0b0110111111101000
STR R1, 0x4

; " "
MOV R0, 0b0010000011101000
STR R1, 0x5

; w
MOV R0, 0b0111011111101000
STR R1, 0x6

; o
MOV R0, 0b0110111111101000
STR R1, 0x7

; r
MOV R0, 0b0111001011101000
STR R1, 0x8

; l
MOV R0, 0b0110110011101000
STR R1, 0x9

; d
MOV R0, 0b0110010011101000
STR R1, 0xA

; Return to start without clearing RAM
CMP R0, R0
JE 0

; Return clearing RAM
;RES