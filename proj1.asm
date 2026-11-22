[org 0x0100]
start:
    mov ax, 13h
    int 10h

   
    mov ax, 1010h        
    mov bx, 0Ch          
    mov dh, 58           
    mov ch, 30         
    mov cl, 7            
    int 10h

    mov di, 0
    mov cx, 32000
    call draw_sky

    mov di, 29760
    mov cx, 17120
    call draw_ground

    mov di, 6415
    mov cx, 60
    call draw_bar

   
    mov di, 29880      
    mov cx, 40        
    call draw_road

  
    mov di, 160
    mov cx, 3
    call draw_lanes

    mov di, 118*320+147     
    call draw_car_blue
    mov di, 100*320+188     
    call draw_car_teal

 
    call draw_bonnet

    mov di, 53760
    mov cx, 5120
    call draw_dashboard

    mov di, 172*320+97
    call draw_speedbox

    mov di, 176*320+176
    call draw_fuel

    call draw_wheel

    mov di, 52443
    mov cx, 37
    call draw_spoke

    call draw_hub
    call draw_texts

    mov di, 0
    mov cx, 16*320
    call draw_textbg
    mov ax, 0x4c00
    int 0x21


draw_sky:
    push es
    push ax
    push cx
    push di
    mov ax, 0xa000
    mov es, ax
    mov al, 09h
    mov ah, al
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
    mov al, 02h
    mov ah, al
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
    push bx
    mov bx, cx
    mov ax, 0xa000
    mov es, ax
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
    mov cx, bx
    add di, 320
loop1:
    push di
    mov dx, 5
loop2:
    mov [es:di], al
    inc di
    dec dx
    cmp dx, 0
    jne loop2
    pop di
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
    mov cx, bx
    add di, 320
loop3:
    push di
    mov dx, 5
loop4:
    mov [es:di], al
    inc di
    dec dx
    cmp dx, 0
    jne loop4
    pop di
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
    pop bx
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
    mov dx, 107
    mov bx, cx
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
    push bx
    push cx
    push dx
    push di
    mov ax, 0xa000
    mov es, ax
    xor bx, bx            
bon_col:
    mov ax, bx
    sub ax, 160            
    imul ax                  
    mov cx, 25600
    sub cx, ax               
    mov ax, cx
    shr ax, 8               
    mov dl, 23
    mul dl                   
    mov dl, 100
    div dl                  
    xor ah, ah
    mov cx, ax              
    jcxz bon_next           
    mov di, 168
    sub di, cx               
    mov dx, di
    shl di, 6
    shl dx, 8
    add di, dx               
    add di, bx              
bon_fill:
    mov byte [es:di], 0Ch
    add di, 320
    loop bon_fill            
bon_next:
    inc bx
    cmp bx, 320
    jne bon_col
    pop di
    pop dx
    pop cx
    pop bx
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
    push bx
    mov bx, cx
    mov ax, 0xa000
    mov es, ax
    mov dx, 5
    mov al, 00h
spoke_row:
    mov cx, bx
    cld
    rep stosb
    add di, 320
    sub di, bx
    dec dx
    jnz spoke_row
    pop bx
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
    push si
    mov si, di
    mov ax, 0xa000
    mov es, ax
    mov bx, 93
lane_row:
    test bx, 4
    jnz lane_skip
    mov ax, bx
    sub ax, 53             
    xor dx, dx
    div cx
    mov di, bx
    shl di, 6
    mov dx, bx
    shl dx, 8
    add di, dx
    add di, si
    sub di, ax
    mov word [es:di], 0f0fh
    add di, ax
    add di, ax
    mov word [es:di], 0f0fh
lane_skip:
    inc bx
    cmp bx, 145
    jne lane_row
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    ret


draw_car_blue:
    push ax
    push bx
    push dx
    push di
    push si
    mov si, di
    mov bx, 26             
    mov dx, 18
    mov al, 01h
    call draw_rect
    mov di, si               
    add di, 3*320
    add di, 4
    mov bx, 18
    mov dx, 6
    mov al, 00h
    call draw_rect
    mov di, si            
    add di, 13*320
    add di, 2
    mov bx, 4
    mov dx, 3
    mov al, 04h
    call draw_rect
    mov di, si              
    add di, 13*320
    add di, 20
    mov bx, 4
    mov dx, 3
    mov al, 04h
    call draw_rect
    pop si
    pop di
    pop dx
    pop bx
    pop ax
    ret


draw_car_teal:
    push ax
    push bx
    push dx
    push di
    push si
    mov si, di
    mov bx, 13              
    mov dx, 8
    mov al, 03h
    call draw_rect
    mov di, si              
    add di, 1*320
    add di, 2
    mov bx, 9
    mov dx, 3
    mov al, 00h
    call draw_rect
    mov di, si             
    add di, 5*320
    mov bx, 3
    mov dx, 2
    mov al, 04h
    call draw_rect
    mov di, si               
    add di, 5*320
    add di, 10
    mov bx, 3
    mov dx, 2
    mov al, 04h
    call draw_rect
    pop si
    pop di
    pop dx
    pop bx
    pop ax
    ret

draw_speedbox:
    push ax
    push bx
    push dx
    push di
    mov bx, 60
    mov dx, 24
    mov al, 0fh
    call draw_rect
    add di, 320+1
    mov bx, 58
    mov dx, 22
    mov al, 00h
    call draw_rect
    pop di
    pop dx
    pop bx
    pop ax
    ret

draw_fuel:
    push ax
    push bx
    push dx
    push di
    mov bx, 56
    mov dx, 8
    mov al, 0fh
    call draw_rect
    add di, 320+1
    mov bx, 54
    mov dx, 6
    mov al, 00h
    call draw_rect
    mov bx, 27
    mov dx, 6
    mov al, 0ah
    call draw_rect
    pop di
    pop dx
    pop bx
    pop ax
    ret
draw_text:
    push ax
    push bx
    push es
    push bp
    mov ax, ds
    mov es, ax
    mov ax, 1300h
    mov bh, 0
    int 10h
    pop bp
    pop es
    pop bx
    pop ax
    ret
draw_texts:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov dh, 0
    mov dl, 5
    mov bl, 0fh
    mov bp, text_dist
    mov cx, 17
    call draw_text
    mov dh, 1
    mov dl, 5
    mov bl, 0eh
    mov bp, text_score
    mov cx, 10
    call draw_text
    mov dh, 1
    mov dl, 0
    mov bl, 0fh
    mov bp, text_time
    mov cx, 4
    call draw_text
    mov dh, 22
    mov dl, 14
    mov bl, 0eh
    mov bp, text_speed
    mov cx, 3
    call draw_text
    mov dh, 23
    mov dl, 14
    mov bl, 0fh
    mov bp, text_kmh
    mov cx, 4
    call draw_text
    mov dh, 21
    mov dl, 22
    mov bl, 0fh
    mov bp, text_fuel
    mov cx, 4
    call draw_text
    mov dh, 23
    mov dl, 22
    mov bl, 0fh
    mov bp, text_e
    mov cx, 1
    call draw_text
    mov dh, 23
    mov dl, 28
    mov bl, 0fh
    mov bp, text_f
    mov cx, 1
    call draw_text
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret


draw_textbg:
    push es
    push ax
    push cx
    push di
    mov ax, 0xa000
    mov es, ax
textbg_loop:
    cmp byte [es:di], 00h
    jne textbg_skip
    mov byte [es:di], 09h
textbg_skip:
    inc di
    loop textbg_loop
    pop di
    pop cx
    pop ax
    pop es
    ret

text_dist: db 'DIST 420 / 1000 m'
text_score: db 'SCORE 4793'
text_time: db 'Time'
text_speed: db '078'
text_kmh: db 'km/h'
text_fuel: db 'FUEL'
text_e: db 'E'
text_f: db 'F'