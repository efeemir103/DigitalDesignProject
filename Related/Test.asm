; Load button data:
LD R1, 0x0

MOV R2, 2
MOV R3, 1
MOV R4, 0
MOV R5, 0

ADD R1, R1, R3

; START Multiplication LOOP:
ADD R4, R4, R2
DEC R1, R3

; debug
; STR R1, 0x1

CMP R1, R5
JNE 5
; END Multiplication LOOP;

; Write to digital tube:
STR R4, 0x1
RES