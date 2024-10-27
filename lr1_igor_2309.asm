.model small
.186
.stack 100h
.data
A db 1 dup(?); выделяется память 1 байт, но  не устанавливается какое-либо конкретное значение
B db 1 dup(?)
C db 1 dup(?) ; все что выше 73 переполнение 74+ 4Ah до B6
D dw ?
message db "A = +000 B = +000 C = +000", 0Ah, 0Dh
filename db "perepoln.txt", 0 ; там где будет выводиться результат, в дебагере чтобы текст не сливался 
handle	dw ?; переменная отвечающая за хранение файла (из мануала)
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
	jmp checking_znam; ближайший переход по метке

program_main2:
	mov bp, 1000h
checking_znam:
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

chis:
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
	;mov bx, 10h; перевод в аски код, чторбы отделять циферки
	call a_output
	call write_file
	cmp bp, 0FFFh ; цикл или не цикл
	je Z_end
				
our_circle: 	

next_a:
    cmp [A], 7Fh          ; Проверяем, достигло ли A значения 127
    je next_b              ; Если A равно 127, переход к следующей переменной B
    inc [A]                ; Увеличиваем A
    jmp next_circle        ; Возвращаемся к началу цикла

next_b:
    mov [A], 80h           ; Если A достигло предела, переустанавливаем его на -128
    cmp [B], 2h           ; Проверяем, достигло ли B значения 127
    je next_c              ; Если B равно 127, переход к следующей переменной C
    inc [B]                ; Увеличиваем B
    jmp next_circle        ; Возвращаемся к началу цикла

next_c:
    mov [B], 0h           ; Если B достигло предела, переустанавливаем его на -128
    cmp [C], 7Fh           ; Проверяем, достигло ли C значения 127
    je Z_end               ; Если C равно 127, завершение
    inc [C]                ; Увеличиваем C
    jmp next_circle        ; Возвращаемся к началу цикла

next_circle:	
	jmp checking_znam
Z_end:
	call close_file
Z:
	mov ah, 4Ch
	int 21h

create_file:
    mov ah, 3Ch
    mov dx, offset filename
    mov cx, 0h
    int 21h
    mov handle, ax
    ;lea di, buffer
    ret

a_output:
	mov 	al, A
	or	al, al
	jge 	a_output_pol
	neg 	al
	mov 	[message + 4], '-'
a_output_pol:
	aam
        or      al, 30h
        mov     [message + 7], al
        mov     al, ah
        aam
        or      al, 30h
        mov     [message + 6], al
        or      ah, 30h
        mov     [message + 5], ah


	mov 	al, B
	cmp	ax, 7Fh
	jge b_output_pol
	neg al
	mov 	[message + 13], '-'
b_output_pol:
	aam
        or      al, 30h
       	mov 	[message + 16], al
        mov     al, ah
        aam
        or      al, 30h
        mov 	[message + 15], al
        or      ah, 30h
        mov 	[message + 14], ah


	mov 	al, C
	cmp	ax, 7Fh
	jge c_output_pol
	neg al
	mov 	[message + 22], '-'

c_output_pol:
	aam
        or      al, 30h
        mov 	[message + 25], al
        mov     al, ah
        aam
        or      al, 30h
        mov 	[message + 24], al
        or      ah, 30h
        mov 	[message + 23], ah
ret

write_file:
    mov bx, handle
    mov ah, 40h
    mov cx, 28            ; Количество записываемых байт
    mov dx, offset message
    int 21h
    ret

close_file:
    mov bx, handle
    mov ah, 3Eh
    int 21h
ret

end start

