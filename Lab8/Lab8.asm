;��������� 1, 2, 3: ����� ������ (����, ������, �������)
;��������� 4, 5, 6: ������������ (����, ������, �������)
.model tiny                ;
.code                      ;
	org 100h               ; ������ PSP
                           ;
start:                     ;
	jmp main               ;
                           ;
;data                      ;
startHour       db 0       ;
startMinutes    db 0       ; ����� ������
startSeconds    db 0       ;
                           ;
durationHour    db 0       ; 
durationMinutes db 0       ; ����������������� �������
durationSeconds db 0       ;
                           ;
stopHour        db 0       ;
stopMinutes     db 0       ; ����� � ����������� ������ �������
stopSeconds     db 0       ;
                           
badCMDArgsMessage db "Bad command-line arguments. I want only 6 arguments: start time (hour, minute, second) and duration time (hour, minute, second)", '$'
 
isAlarmOn db 0
                           
;**********************************************************************************************************************
;                                                        BANNER
;**********************************************************************************************************************                           
widthOfBanner   equ 40     ; ������ ���������� �������
allWidth        equ 80     ; ������ ������ ������� DOS-box
red             equ 4020h  ;
white           equ 7020h  ; ����� + ��������� �������. 4020h : 40 - ��� �������� �����, 20 - ��� ������� �������� ��������������
black           equ 0020h  ;

wakeUpText 	dw widthOfBanner dup(red)
			dw 4 dup(red), white, 5 dup(red), white, 2 dup(red), 2 dup(white), red, white, red, 2 dup(white), red, 3 dup(white), 4 dup(red), white, 2 dup(red), white, red, 3 dup(white), 4 dup(red)
			dw 4 dup(red), white, 5 dup(red), 5 dup(white, red), red, white, 6 dup(red), white, 2 dup(red), 3 dup(white, red), 3 dup(red)
			dw 5 dup(red), 3 dup(white, red), red, 3 dup(white), red, 2 dup(white), 3 dup(red), 2 dup(white), 5 dup(red), white, 2 dup(red), white, red, 3 dup(white), 4 dup(red)
			dw 5 dup(red), 3 dup(white, red), 4 dup(red, white), 2 dup(red), white, 6 dup(red), white, 2 dup(red), 2 dup(white, red), 5 dup(red)
			dw 6 dup(red), 2 dup(white, red), 2 dup(red), 3 dup(white, red), 2 dup(white), red, 3 dup(white), 5 dup(red), 2 dup(white), 2 dup(red), white, 6 dup(red)
			dw widthOfBanner dup(red)

offWakeUp	dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black) ; �������� ������ �� ������� �����, ������� ������������ ������ ���������� ����������, 
			dw widthOfBanner dup(black) ; ����� ��� ���������, ����� ��� ���������� ������
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)     
;**********************************************************************************************************************
;                                                     END  BANNER
;**********************************************************************************************************************
                                      ;
intOldHandler dd 0                    ;
                                      ;
handler PROC                          ; ����� ���������� ����������
	pushf                             ;
	                                  ;
	call cs:intOldHandler             ; �������� ������� ���������� ����������
	push ds                           ;
    push es                           ;
	push ax                           ;
	push bx                           ; ��������� ��������
    push cx                           ;
    push dx                           ;
	push di                           ;
                                      ;
	push cs                           ;
	pop ds                            ;
                                      ;
	mov ah, 02h                       ;	02H �AT� ������ ����� �� "����������" (CMOS) ����� ��������� �������
	int 1Ah                           ;   �����: CH = ���� � ���� BCD   (������: CX = 1243H = 12:43) 
	                                  ;          CL = ������ � ���� BCD
                                      ;          DH = ������� � ���� BCD
                                      ;   �����: CF = 1, ���� ���� �� ��������
	                                  ; 
	cmp ch, startHour                 ; �������� �� ����������� ��������� ����������
	jne stopCheck                     ;
	cmp cl, startMinutes              ; ���� ������� ����� �� ����� ������� ������������ ���������� - ���������� �������� 
	jne stopCheck                     ;
	cmp dh, startSeconds              ;
	jne stopCheck                     ;
	                                  ;
	                                  ; ���������� ������� ��������� ����������
	mov dl, isAlarmOn                 ; ���� �������� �� ������� - ���������� ��������
	cmp dl, 0                         ;
	jne stopCheck                     ;
                                      ;
	                                  ; here => start alarm
	mov si, offset wakeUpText         ; ��������� � si ����������� ���������
	call printBanner                  ; �������� ����� ���������, ������������ � si
	mov dl, 1                         ; 
	mov isAlarmOn, dl                 ; ������������� ��������� ���������� � 1
                                      ; ����������� ���������
	jmp endHandler                    ;
                                      ;
stopCheck:                            ; �������� �� ����������� ���������� ����������
	cmp ch, stopHour                  ;
	jne endHandler                    ;
	cmp cl, stopMinutes               ; ���� ������� ����� != ����� ���������� - ���������� ��������
	jne endHandler                    ;
	cmp dh, stopSeconds               ;
	jne endHandler                    ;
 	                                  ; ���������� ������� ��������� ����������
	mov dl, isAlarmOn                 ;
	cmp dl, 1                         ; ���� ��������� �� ������� - ����������� �������� 
	jne endHandler                    ;
                                      ;
	                                  ; 
	mov si, offset offWakeUp          ; ������� ��������� ����������
	call printBanner                  ; ��������� � si, ���������, ���������� ���������� "Wake Up"
	mov dl, 0                         ;
	mov isAlarmOn, dl                 ; ������������� ��������� ���������� � 0
                                      ;
endHandler:                           ;
	pop di                            ;
	pop dx                            ;
	pop cx                            ;
	pop bx                            ; ��������������� ��������
	pop ax                            ;
	pop es                            ;
	pop ds	                          ;
	iret                              ;
ENDP                                  ;
                                      ;	
printBanner PROC                      ; ��������� ������ �������
	push es                           ; � si ��������� �������� ���������� ���������
	push 0B800h                       ; ��������� � 16-������ ������� ������
                                      ; 0b800h ������������� �������� ������� � �������� ������
	pop es                            ; ES=0B800h
                                      ;
	mov di, 9*allWidth*2 + (allWidth - widthOfBanner) ; ����� ������� ���� ������ ������
	mov cx, 7                         ; ���-�� ����� �������
loopPrintBanner:                      ;
	push cx                           ; ��������� �������� cx
                                      ;
	mov cx, widthOfBanner             ; ��������� � cx ������ ���������� �������, �.�. ����� ������ �������
	rep movsw                         ; rep - ��������� cx ���, movsw - �������� � ������ es:di ������ �� ds:si
                                      ;
	add di, 2*(allWidth - widthOfBanner); ��������� �� ����� ������
                                      ;
	pop cx                            ; ��������������� �������� cx
	loop loopPrintBanner              ;
                                      ;
	pop es                            ;
	ret                               ;
ENDP                                  ;
                                      ;
programLength:                        ; ������� ��������� ������
                                      ; ���������: ax = 0 ���� ��� ��, ����� !=0
parseCMD PROC                         ;
	push bx                           ;   
	push cx                           ;
	push dx                           ; ��������� �������� ���������
	push si                           ;
	push di                           ;
                                      ;
	cld                               ;
	mov bx, 80h                       ;
	mov cl, cs:[bx]                   ; ��������� � ��������, ��� ���������� ����� ��������� ������
	xor ch, ch                        ; � cl ��������� ����� ��������� ������
                                      ;
	xor dx, dx                        ;
	mov di, 81h                       ;
                                      ;
	mov al, ' '                       ; ���������� ��� �� ��������
	repne scasb	                      ; ����� ����, ������ al � ����� �� cx ���� �� ������ es:di
	xor ax, ax                        ;
                                      ;
	mov si, di                        ; ��������� � si ��������, � �������� ���������� ���������
	mov di, offset startHour          ; �������� ������� � startHour
                                      ;
parseCMDloop:                         ;
	mov dl, [si]                      ; ��������� � dl ��������� ������ �� ��������� ������
	inc si                            ; ��������� � ���� ��������
	cmp dl, ' '                       ; ���� ������ = ������, ��������� � SpaceIsFound
	je SpaceIsFound                   ;
                                      ;
	cmp dl, '0'                       ;
	jl badCMDArgs                     ; ���� ������ �� ����� - ������
	cmp dl, '9'                       ;
	jg badCMDArgs                     ;
                                      ;
	sub dl, '0'                       ; �������� � dl ����� �� �������
	mov bl, 10                        ;
	mul bl                            ; �������� ax �� 10
	add ax, dx                        ; ��������� � ax dx 
                                      ;
	cmp ax, 60                        ; ���������� ax � 60 - ���� ������, �� �������� ������
	jae badCMDArgs				      ; ja - jump after
	cmp ax, 24                        ; ���� ������ 24, ��������� �������� �����
	jae testIsHour                    ;
                                      ;
	loop parseCMDloop                 ;
                                      ;
SpaceIsFound:                         ;
	mov byte ptr es:[di], al          ; ������� ������������ ����� � ����������� ��������
	cmp di, offset durationSeconds    ; ���� ��������� ��������� ������� - ����������������� � �������� - ���� ����������
	je argsIsGood                     ;
                                      ;
	inc di                            ; ����� ����������� di �� 1 � ���������� ������� ��� ��� ���������� ��������
	xor ax, ax                        ; ���������� ����������� � 0
                                      ;
	loop parseCMDloop                 ; ���� ������� ������ ��� ������ - ��������� � argIsGood
	jmp argsIsGood                    ;
                                      ;
testIsHour:                           ;
	cmp si, offset startHour          ; 
	je badCMDArgs                     ; ���������, ���� ������� �������� �������� - ��� ������ ��� ����������������� � ����� - ���� �����������
	cmp si, offset durationHour       ;
	je badCMDArgs                     ;
	                                  ;
	loop parseCMDloop                 ; ���� ������ �� ��������� - ���������� ������� ������
	jmp SpaceIsFound                  ;
                                      ;
badCMDArgs:                           ;
	mov dx, offset badCMDArgsMessage  ; ������� ��������� �� ������
	call println                      ; �������� ��������� ������
	mov ax, 1                         ; ��������� � ax 1, �.� ������� ������
                                      ;
	jmp endproc                       ; ��������� � ���������� ���������
                                      ;
argsIsGood:                           ;
	mov ax, 0                         ; ��������� � ax = 0, �.� ������ �� ���������
                                      ;
endproc:                              ;
	pop di                            ;
	pop si                            ;
	pop dx                            ; ��������������� �������� ��������� � ������� �� ���������
	pop cx                            ;
	pop bx                            ;
	                                  ;
	ret	                              ;
ENDP                                  ;
                                      ;                        
                                      ; 
setHandler PROC                       ; ��������� ������ ����������� ����������. ��������� ax=0 ���� ��� ������, ����� ax!=0 
	push bx                           ;
	push dx                           ; ��������� �������� ���������
                                      ;
	cli                               ; ��������� ���������� (������/���������� ���������� ��� ���������� ��������� ������ ����������� )
                                      ;
	mov ah, 35h                       ; ������� ��������� ������ ����������� ����������
	mov al, 1Ch                       ; ����������, ���������� �������� ���������� �������� (1C - ���������� �������)
	int 21h                           ; �������� ���������� ��� ��������� ������� 
                                      ; � ���������� ���������� ������� � es:bx ���������� ����� �������� ����������� ����������                                                 
                                      ;
	                                  ; ��������� ������ ����������
	mov word ptr [offset intOldHandler], bx     ;
	mov word ptr [offset intOldHandler + 2], es ;
                                      ;
	push ds			                  ; ��������� �������� ds
	pop es                            ; ��������������� �������� es
                                      ;
	mov ah, 25h                       ; ������� ������ ����������� ����������
	mov al, 1Ch                       ; ����������, ��������� �������� ����� �������
	mov dx, offset handler            ; ��������� � dx �������� ������ ����������� ����������, ������� ����� ���������� �� ����� ������� ����������� 
	int 21h                           ; �������� ���������� ��� ���������� �������
                                      ;
	sti                               ; ��������� ����������
                                      ;
	mov ax, 0                         ; ��������� � ax - 0, �.�. ������ �� ���������
                                      ;
	pop dx                            ; ��������������� �������� ��������� � ��������� ������� �� ���������
	pop bx                            ;
	ret                               ;
ENDP                                  ;
                                      ;
newline PROC                          ;
	push ax                           ; ��������� �������� ���������
	push dx                           ;
                                      ;
	mov dl, 10                        ;	��������� � dx ��������������� ���� �������� ������� 0Ah(10) � 0Dh(13) ��� �������� �� ����� ������
	mov ah, 02h                       ; ��������� � ax ��� 02h - ��� �������� ������ �������
	int 21h                           ; �������� ���������� ��� ������ �������
                                      ;
	mov dl, 13                        ;
	mov ah, 02h                       ; ==//==
	int 21h                           ;
                                      ;
	pop dx                            ; ��������������� ������� ���������
	pop ax                            ;
	ret                               ;
ENDP                                  ;
                                      ;
println PROC                          ;
	push ax                           ; ��������� �������� ���������
	push dx                           ;
                                      ;
	mov ah, 09h                       ; ��������� � ah ��� ������ ������ (� di ��� ��������� ��������� ����������)
	int 21h                           ; �������� ���������� ��� ���������� ������
                                      ;
	call newline                      ; �������� newline, �.�. ��������� �� ����� ������
                                      ;
	pop dx                            ; ��������������� �������� ��������� � ������� �� ���������
	pop ax                            ;
	ret                               ;
ENDP                                  ;
                                      ; ��������� ���������� �������, � ������� ���������� ��������� ���������
calcucateStopTime PROC                ;
	xor ah, ah                        ; �������
	mov al, startSeconds              ; ��������� ����� ������
	add al, durationSeconds           ; ��������� ����������������� 
	mov bl, 60			              ; ����� �� 60
	div bl                            ; ������� - al, ������� - ah
	mov stopSeconds, ah               ; ���������� �� "����� ��������� � ��������" ������� �� ������� �� 60
                                      ; 
                                      ; ����� ������� �� 60 � al ����� ��������� 1, �.�. ��������� ������� 
                                      ;
	xor ah, ah                        ; ������
	add al, startMinutes              ; ��������� ����� ������ � �������
	add al, durationMinutes           ; 
	mov bl, 60			              ;   ==//==
	div bl                            ; 
	mov stopMinutes, ah               ;
	                                  ; ����
	xor ah, ah                        ;
	add al, startHour                 ;
	add al, durationHour              ;   ==//==
	mov bl, 24			              ;
	div bl                            ;
	mov stopHour, ah                  ;
                                      ;
	ret                               ;
ENDP                                  ;
                                      ;
convertToBCD PROC                     ;
	mov cx, 9                         ; ��������� � cx 9, ����� ��������� ��� �����
	                                  ; �.�. 9 = 3*3 = (���� + ������ + �������) * (����� ������ + ����������������� + ����� ���������)
	mov bl, 10                        ; =//= � bx 10
	mov si, offset startHour          ; ������������� si �� startHour, �.� ����� ������ ���������� � �����
convertLoop:                          ; 
	xor ah, ah                        ; �������� ah
	mov al, [si]                      ; ��������� ��������� ������
	div bl                            ; ����� �� 10. ������� - al, ������� - ah
                                      ;
	mov dl, al                        ; ��������� � dl al, �.�.  �������  �� ������� �� 10
	                                  ; 
	shl dl, 4                         ; ����� ����� �� 4 (���������� ��� BCD �������)
	                                  ; ������: 12 = 0001 0010
	                                  ;
	add dl, ah                        ; ��������� � dl ah, �.�  ������� �� ������� �� 10
	mov [si], dl                      ; ������������ ������� � si �� ����� � ������� bcd
                                      ;
	inc si                            ; ��������� � ���������� ��������
	loop convertLoop                  ;
	                                  ;
	ret                               ;
ENDP                                  ;
                                      ;
main:                                 ;
	call parseCMD                     ; ������ ��������� ������
	cmp ax, 0                         ; ���� �������� ������ - �������
	jne endMain                       ; 
                                      ;
	call calcucateStopTime            ; ��������� ����� ��������� ����������
                                      ;
	call convertToBCD                 ; ��������� �������� ������� ������/ �����������������/ ��������� ������� � BCD ���
	                                  ; ��� ������������ ���������� �������������� � ��������� �������� ��������� �������
                                      ;
	call setHandler                   ; ������������� ����� ���������� ����������
	cmp ax, 0                         ; ���� �������� ������ - �������
	jne endMain				          ; 
                                      ;
	mov ah, 31h                       ; ��������� ��������� �����������
	mov al, 0                         ;    
	                                  ;
	mov dx, (programLength - start + 100h) / 16 + 1 ; ������� � dx ������ ��������� + PSP,
	                                  ; ����� ��  16, �.�. � dx ���������� ������� ������ � 16 ������� ����������
	int 21h                           ; 
                                      ;
endMain:                              ;
	ret                               ;                               ;
end start                             ;