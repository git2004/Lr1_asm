.model small
.186
.stack 100h
.data
A db 1 dup(?)
B db 1 dup(?)
C db 1 dup(?) ; все что выше 73 переполнение 74+ 4Ah
D dw ?
message1 dw "=A", 0dh
message2 dw "=B", 0dh, 0ah
message3 dw "=C", 0dh, 0ah
message4 db "-", 0dh, 0ah
filename db "perepoln.txt", 0
handle	dw ?
buffer	db 8192 dup(?)
.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	mov al, A
	or al, al
	jnz program_main2
	mov al, B
	or al, al
	jnz program_main2
	mov al, C
	or al, al
	jnz program_main2
	
	mov bp, 1h
	jmp checking

program_main2:
	mov bp, 1000h
checking:
	xor dx,dx 
	mov al, C
	imul al 
	shl ax, 2 
	mov bx, ax 
	shl ax, 1 
	add ax, bx 
	adc dx , 0h
	mov bl, A  
	xchg ax,bx 
	cbw  
	add ax, bx 
	jz ZZ 
	cmp dh, dl
	jne perepoln

	mov si, ax
	mov al, A
	imul al
	mov bl, C
	xchg ax,bx
	cbw 
	sub bx,ax
	xor ax, ax
	xchg bx, di

	mov al, B
	cbw
	mov cx, ax; cx b
	shl ax, 2 ; 4b
	mov bx, ax ; bx 4b
	shl ax, 5; 128b
	add ax, cx; 129b
	xchg ax,cx
	imul ax
	xchg ax,cx
	imul bx; 516b^2
	add ax, cx; 517b^2
	add ax, di
	mov bx, si
	idiv bx
	mov [D], ax
	xor si,si
ZZ:
	cmp bp, 1000h
	jne our_circle
	jmp Z

perepoln:
	cmp bp, 1h
	je creating
	cmp bp, 1000h
	je creating

	jmp next_loop

creating:
	dec bp
	call create_file
	
next_loop:
	mov bx, 10h
	call a_output
	call b_output
	call c_output
	call write_file
	lea di, buffer
	cmp bp, 0FFFh
	je Z_end
				
our_circle: 	

next_a:
	cmp [A], 0FFh
	je next_b
	inc [A]
	;inc [A]
	jne next_circle
next_b:
	mov [A], 0h
	cmp [B], 0FFh
	je next_c
	inc [B]
	jne next_circle
next_c:
	mov [B], 0h
	cmp [C], 0FFh
	je Z_end
	inc [C]

next_circle:	
	jmp checking
Z_end:
	call close_file
Z:
mov ah, 4Ch
int 21h

create_file:	
	mov	ah, 3ch
	mov	dx, offset filename
	mov	cx, 0h
	int 21h
	mov	handle, ax
	lea di, buffer
ret

a_output:
	mov ax, message1
	stosw
	xor	ax, ax
	mov 	al, A
	xor	cx, cx
	call 	to_ascii
	inc	di
ret

b_output:
	mov ax, message2
	stosw
	xor	ax, ax
	mov 	al, B
	mov	bx, 10h
	xor	cx, cx
	call 	to_ascii
	inc	di
ret

c_output:
	mov ax, message3
	stosw
	xor	ax, ax
	mov 	al, C
	mov	bx, 10h
	xor	cx, cx
	call 	to_ascii
	mov	al, 0ah
	mov	[di], al
	;inc	di
ret

write_file:
	mov	bx, handle
	mov	ah, 40h
	mov	cx, 14h
	mov	dx, offset buffer
	int 21h
ret

close_file:
	;mov	bx, handle
	;mov	ah, 3eh
	;int 21h
	mov	al, '$'
	inc	di
	mov	[di], al
	;mov	ah, 09h
	;int 21h
ret

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

