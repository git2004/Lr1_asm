.model small
.186
.stack 100h
.data
A db 126
B db -110
C db -14
D dw ?
message1 dw "=A", 0dh, 0ah
message2 dw "=B", 0dh, 0ah
message3 dw "=C", 0dh, 0ah
message4 db "-", 0dh, 0ah
filename db "perepoln.txt", 0
handle	dw ?
buffer	db 4096 dup(?)
.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	xor dx,dx 
	mov al, C ;c
	imul al  ;c2
	shl ax, 2 
	mov bx, ax 
	shl ax, 1 
	add ax, bx 
	adc dx , 0h ;для чего это нужно?
	mov bl, A  
	xchg ax,bx 
	cbw  
	add ax, bx 
	jz ZZ 
	cmp dh, dl
	jne perepoln
	mov si, ax
	mov al, a ; дописано
	imul al ; непонятно
	mov bl, C
	xchg ax,bx
	cbw 
	sub bx,ax
	mov al, B
	imul al
	mov cx,ax 
	CWD
	shl ax, 2 
	mov di, ax
	CWD
	shl ax, 7 ; переполнение
	add ax, cx 
	CWD
	add ax, di 
	add ax, bx 
	idiv si
	mov [D], ax
	xor si,si
	jmp Z
	
	jmp perepoln

ZZ:
	jmp Z

perepoln:

;create file	
	mov	ah, 3ch
	mov	dx, offset filename
	mov	cx, 0h
	int 21h
	mov	handle, ax
	
	lea di, buffer
	mov	bx, 10h

A_output:
	mov ax, message1
	stosw
	xor	ax, ax
	mov 	al, A
	xor	cx, cx
	call 	to_ascii
	inc	di

B_output:
	mov ax, message2
	stosw
	xor	ax, ax
	mov 	al, B
	mov	bx, 10h
	xor	cx, cx
	call 	to_ascii
	inc	di

C_output:
	mov ax, message3
	stosw
	xor	ax, ax
	mov 	al, C
	mov	bx, 10h
	xor	cx, cx
	call 	to_ascii
	mov	al, 0dh
	mov	[di], al
	inc	di
;test
	mov ax, message3
	stosw

;write file
	mov	bx, handle
	mov	ah, 40h
	mov	cx, 200h
	mov	dx, offset buffer
	int 21h

;close file
	mov	bx, handle
	mov	ah, 3eh
	int 21h
	mov	al, '$'
	inc	di
	mov	[di], al
	mov	ah, 09h
	int 21h

Z:
mov ah, 4Ch
int 21h

to_ascii:
	xor	dx, dx
	div	bx 
st1:
	inc	cx
	cmp	ax, 9h
	jng	add30h
	add	ax, 37h
	jmp	nxt
add30h:
	add	al, 30h
nxt:
	stosb
	xchg	ax, dx
	cmp 	cx, 1h
	je	st1
	mov  	al, "h"
	mov 	[di], al
	inc 	di
ret

end start

