[org 0x0100]
start:
mov ax, 13h
int 10h

call draw_sky
call draw_ground
call draw_bar
call draw_road
call draw_lanes
call draw_cars
call draw_bonnet
call draw_dashboard
call draw_wheel

call draw_spoke
call draw_hub
mov ax, 0x4c00
int 0x21










draw_sky:
push es
push ax
push cx
push di
mov ax, 0xa000
mov es, ax
mov cx, 32000
mov al, 09h
mov ah, al
mov di, 0
rep stosw
pop di
pop cx
pop ax
pop es
ret
draw_ground:
push es
push ax
push cx
push di
mov ax, 0xa000
mov es, ax
mov cx, 17120
mov al, 02h
mov ah, al
mov di, 29760
rep stosw
pop di
pop cx
pop ax
pop es
ret
draw_bar:
push es
push ax
push cx
push di
push dx
mov ax, 0xa000
mov es, ax
mov di, 6415
mov al, 00h
mov ah, al
draw_corner:
mov [es:di], ax
add di, 2
sub di, 320
mov [es:di], ax
sub di, 1
mov [es:di], al
add di, 2
mov [es:di], al

add di, 320
mov [es:di], ax
sub di, 1
mov [es:di], ax
sub di, 1
mov [es:di], ax
sub di, 1
mov cx, 60
add di, 320
loop1:
mov dx, 5
loop2:
mov [es:di], al
inc di
dec dx
cmp dx, 0
jne loop2
sub di, 5
add di, 320
loop loop1
mov al, 0eh
mov ah, al
draw_corner2:
mov [es:di], ax
add di, 2
sub di, 320
mov [es:di], ax
sub di, 1
mov [es:di], al
add di, 2
mov [es:di], al

add di, 320
mov [es:di], ax
sub di, 1
mov [es:di], ax
sub di, 1
mov [es:di], ax
sub di, 1
mov cx, 60
add di, 320
loop3:
mov dx, 5
loop4:
mov [es:di], al
inc di
dec dx
cmp dx, 0
jne loop4
sub di, 5
add di, 320
loop loop3
mov al, 0eh
mov ah, al
mov [es:di], ax
add di, 2
add di, 320
mov [es:di], ax
sub di, 1
mov [es:di], al
add di, 2
mov [es:di], al
sub di, 320
mov [es:di], al
sub di, 1
mov [es:di], al
add di, 2
mov [es:di], al
pop dx
pop di
pop cx
pop ax
pop es
ret
draw_road:
	push es
	push ax
	push cx
	push di
	push bx
	push dx
	mov ax, 0xa000
	mov es, ax
	mov ax, 0000h
	mov di, 29900
	mov dx, 107
	mov bx, 20
	loopro:
	mov cx, bx
	rep stosw
	shl bx, 1
	sub di, bx
	shr bx, 1
	add di, 320
	sub di, 1
	add bx, 1
	sub dx, 1
	cmp dx, 0
	jne loopro
	pop dx
	pop bx
	pop di
	pop cx
	pop ax
	pop es
	ret 
draw_bonnet:
	push es
	push ax
	push cx
	push di
	push bx
	push dx
	mov ax, 0xa000
	mov es, ax
	mov di, 57600
	mov bx, 160
	mov ax, 0c0ch
	inloo:
		mov cx, bx
		rep stosw
		shl bx, 1
		sub di, bx
		shr bx, 1
		sub di, 320
		add di, 4
		sub bx, 4
		cmp bx, 16
		jne inloo
	pop dx
	pop bx
	pop di
	pop cx
	pop ax
	pop es
	ret
draw_dashboard:
	push es
	push ax
	push cx
	push di
	mov ax, 0xa000
	mov es, ax
	mov di, 53760
	mov cx, 5120
	mov ax, 0808h
	cld
	rep stosw
	pop di
	pop cx
	pop ax
	pop es
	ret
draw_wheel:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov ax, 0xa000
	mov es, ax
	mov si, 137             
wheel_y:
	mov bx, 277              
wheel_x:
	cmp bx, 319
	ja wheel_skip           
	mov ax, bx
	sub ax, 305              
	imul ax                 
	mov cx, ax
	mov ax, si
	sub ax, 165             
	imul ax                  
	add ax, cx               
	cmp ax, 484              
	jb wheel_skip           
	cmp ax, 784              
	ja wheel_skip            
	mov di, si
	shl di, 6                
	mov dx, si
	shl dx, 8               
	add di, dx              
	add di, bx              
	mov byte [es:di], 00h    
wheel_skip:
	inc bx
	cmp bx, 334             
	jne wheel_x
	inc si
	cmp si, 194             
	jne wheel_y
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	ret
draw_hub:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov ax, 0xa000
	mov es, ax
	mov si, 157             
hub_y:
	mov bx, 297            
hub_x:
	mov ax, bx
	sub ax, 305
	imul ax
	mov cx, ax
	mov ax, si
	sub ax, 165
	imul ax
	add ax, cx
	cmp ax, 64              
	ja hub_skip
	mov di, si
	shl di, 6
	mov dx, si
	shl dx, 8
	add di, dx
	add di, bx
	mov byte [es:di], 08h   
hub_skip:
	inc bx
	cmp bx, 314
	jne hub_x
	inc si
	cmp si, 174
	jne hub_y
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	ret
draw_spoke:
	push es
	push ax
	push cx
	push di
	push dx
	mov ax, 0xa000
	mov es, ax
	mov di, 52443
	mov dx, 5
	mov al, 00h
spoke_row:
	mov cx, 37
	cld
	rep stosb
	add di, 320 - 37
	dec dx
	jnz spoke_row
	pop dx
	pop di
	pop cx
	pop ax
	pop es
	ret
	draw_rect:
	push es
	push ax
	push cx
	push dx
	push di
	mov cx, 0xa000
	mov es, cx
	cld
	rect_row:
		mov cx, bx
		push di
		rep stosb
		pop di
		add di, 320
		dec dx
		jnz rect_row
	pop di
	pop dx
	pop cx
	pop ax
	pop es
	ret
draw_lanes:
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xa000
	mov es, ax
	mov bx, 93
	lane_row:
		test bx, 4
		jnz lane_skip
		mov ax, bx
		sub ax, 73
		xor dx, dx
		mov cx, 3
		div cx
		mov di, bx
		shl di, 6
		mov dx, bx
		shl dx, 8
		add di, dx
		add di, 160
		sub di, ax
		mov word [es:di], 0f0fh
		add di, ax
		add di, ax
		mov word [es:di], 0f0fh
	lane_skip:
		inc bx
		cmp bx, 145
		jne lane_row
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	ret
draw_cars:
	push ax
	push bx
	push dx
	push di
	mov di, 115*320+120
	mov bx, 20
	mov dx, 14
	mov al, 01h
	call draw_rect
	mov di, 117*320+123
	mov bx, 14
	mov dx, 5
	mov al, 00h
	call draw_rect
	mov di, 125*320+121
	mov bx, 3
	mov dx, 2
	mov al, 04h
	call draw_rect
	mov di, 125*320+136
	mov bx, 3
	mov dx, 2
	mov al, 04h
	call draw_rect
	mov di, 100*320+155
	mov bx, 10
	mov dx, 6
	mov al, 03h
	call draw_rect
	mov di, 101*320+157
	mov bx, 6
	mov dx, 2
	mov al, 00h
	call draw_rect
	mov di, 104*320+155
	mov bx, 2
	mov dx, 2
	mov al, 04h
	call draw_rect
	mov di, 104*320+163
	mov bx, 2
	mov dx, 2
	mov al, 04h
	call draw_rect
	pop di
	pop dx
	pop bx
	pop ax
	ret
	
	
	