.model small
.186
.stack 100h
.data
A db 1 dup(?); выделяется память 1 байт, но  не устанавливается какое-либо конкретное значение
B db 1 dup(?)
C db 1 dup(?) ; все что выше 73 переполнение 74+ 4Ah до B6
D dw ?
message1 dw "=A", 0dh, 0ah ; 0dh 0ah так нужно записывать (пробел и перенос), это разделитель, столько конструкций сделано чтобы удобнее было перебегать счетчиком
message2 dw "=B", 0dh, 0ah
message3 dw "=C", 0dh, 0ah
filename db "perepoln.txt", 0 ; там где будет выводиться результат, в дебагере чтобы текст не сливался 
handle	dw ?; переменная отвечающая за хранение файла (из мануала)
buffer	db 20 dup(?) ;(кол-во место выделенное под запись файла)
.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax
;проверяем на зполненность
	mov al, A
	or al, al
	jnz program_main2 ; jnz: выполняет переход к метке, если флаг нуля не установлен
	mov al, B
	or al, al
	jnz program_main2
	mov al, C
	or al, al
	jnz program_main2
	
	mov bp, 1h
	jmp checking; ближайший переход по метке

program_main2:
	mov bp, 1000h
checking:
	xor dx,dx ; исключающее ИЛИ, два одинаковых операнда => равно 0
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
	jz ZZ ; проверка на то равен ли числитель 0
	cmp dh, dl
	jne perepoln ;  выполняет переход к метке, если флаг нуля не установлен (т.е. если произошел выход за рамки ax, и что-то попало в dx, то флаг нуля не уставновлен и переходим к метсе переполнения)

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
	shl ax, 1; ax 2b
	mov bx, ax; bx 2b
	shl bx, 2; bx 8b
	add ax, bx; ax 10b
	add ax, cx; ax 11b
	shl bx, 2; bx 32b
	shl cx, 2; cx 4b
	add bx, cx; bx 36b
	add bx, ax; bx 47b
	imul bx; ax = 47*11 = 517b^2
	add ax, di
	mov bx, si
	idiv bx
	mov [D], ax
	xor si,si
ZZ:
	cmp bp, 1000h; сравниваем значения для bp, если они заданы - то завершаем так как равно 1000, если нет то прыгаем на цикл
	jne our_circle
	jmp Z

perepoln:
	cmp bp, 1h
	je creating ; файл создается только один раз, затем счетчик уменьшается
	cmp bp, 1000h
	je creating

	jmp next_loop

creating:
	dec bp
	call create_file
	
next_loop:
	mov bx, 10h; перевод в аски код, чторбы отделять циферки
	call a_output
	call b_output
	call c_output
	call write_file
	lea di, buffer ; перезаписываем одну и ту же строку в памяти и каждый раз выводим ее прерыванием
	cmp bp, 0FFFh ; цикл или не цикл
	je Z_end
				
our_circle: 	

next_a:
	cmp [A], 0FFh
	je next_b; JE выполняет короткий переход, если первый операнд РАВЕН второму операнду
	inc [A]
	jne next_circle
next_b:				;b не участвует в переполнении
	mov [A], 0h
	cmp [B], 2h
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
ret ; возврат из процедуры 

a_output:
	mov ax, message1
	stosw
	xor	ax, ax
	mov 	al, A
	xor	cx, cx ; выступает как счетчик перед to_ascii
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
	mov	bx, handle
	mov	ah, 3eh
	int 21h
	mov	al, '$' ; символ окончания строки при завершении работы с файлом
	inc	di
	mov	[di], al
	mov	ah, 09h
	int 21h
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

