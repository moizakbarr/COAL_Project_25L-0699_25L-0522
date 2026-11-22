[org 0x0100]
start:
    xor ax, ax
    mov es, ax
    mov ax, [es:8*4]
    mov [oldisr], ax
    mov ax, [es:8*4+2]
    mov [oldisr+2], ax
    mov ax, [es:9*4]
    mov [oldisr1], ax
    mov ax, [es:9*4+2]
    mov [oldisr1+2], ax
    cli
    mov word [es:8*4], timerISR
    mov word [es:8*4+2], cs
    mov word [es:9*4], kbisr
    mov word [es:9*4+2], cs
    sti
    mov ax, 13h
    int 10h

    mov ax, 1010h
    mov bx, 0Ch
    mov dh, 58
    mov ch, 30
    mov cl, 7
    int 10h
    mov ax, cs
    add ax, 1000h
    mov [bufseg], ax
    add ax, 1000h
    mov [textseg], ax

    mov ax, 1130h
    mov bh, 3
    int 10h
    mov [fontoff], bp
    mov [fontseg], es

    call draw_texts
    call save_text

    mov al, [ticks]
    mov [lastticks], al
start1:
tick_loop:
    mov al, [ticks]
    cmp al, [lastticks]
    je ticks_done
    inc byte [lastticks]
    call update
    cmp byte [state], 0
    jne ticks_done
    jmp tick_loop
ticks_done:

    mov di, 0
    mov cx, 32000
    call draw_sky

    mov di, 29760
    mov cx, 17120
    call draw_ground

    mov di, 6415
    call draw_bar

    call draw_road

    mov di, 160
    mov cx, 3
    call draw_lanes

    call draw_traffic

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

    mov di, 0
    mov cx, 16*320
    call overlay_text

    mov di, 53760
    mov cx, 24*320
    call overlay_text

    mov di, 0
    mov cx, 16*320
    call draw_textbg

    call draw_numbers

    cmp byte [crash], 0
    je no_crash_text
    mov di, 7*2560+17*8
    mov si, text_crash
    mov cx, 6
    mov bl, 0fh
    call draw_string
no_crash_text:

    call present

    cmp byte [quit], 1
    jne check_state
    jmp exit
check_state:
    cmp byte [state], 0
    jne endlevel
    jmp start1

endlevel:
    call show_message
wait_esc:
    cmp byte [quit], 0
    je wait_esc
exit:
    xor ax, ax
    mov es, ax
    cli
    mov ax, [oldisr]
    mov [es:8*4], ax
    mov ax, [oldisr+2]
    mov [es:8*4+2], ax
    mov ax, [oldisr1]
    mov [es:9*4], ax
    mov ax, [oldisr1+2]
    mov [es:9*4+2], ax
    sti
    mov ax, 3
    int 10h
    mov ax, 0x4c00
    int 0x21

timerISR:
    inc byte [cs:ticks]
    jmp far [cs:oldisr]

kbisr:
    push ax
    in al, 0x60
    cmp al, 0x01
    jne lanekeys
    mov byte [cs:quit], 1
    jmp done
lanekeys:
    cmp al, 0x4d
    jne nextcmp
    cmp byte [cs:lanenum], 1
    jle done
    dec byte [cs:lanenum]
    jmp done
nextcmp:
    cmp al, 0x4b
    jne holdkeys
    cmp byte [cs:lanenum], 3
    jge done
    inc byte [cs:lanenum]
    jmp done
holdkeys:
    mov ah, 1
    test al, 80h
    jz ismake
    xor ah, ah
    and al, 7Fh
ismake:
    cmp al, 0x48
    jne spacecmp
    mov [cs:upkey], ah
    jmp done
spacecmp:
    cmp al, 0x39
    jne downcmp
    mov [cs:spacekey], ah
    jmp done
downcmp:
    cmp al, 0x50
    jne done
    mov [cs:downkey], ah
done:
    pop ax
    jmp far [cs:oldisr1]


update:
    push ax
    push bx
    push si

    cmp byte [crash], 0
    je crash_over
    dec byte [crash]
    jmp no_up
crash_over:
    cmp byte [upkey], 0
    je no_up
    mov al, [speed]
    add al, 3
    cmp al, 120
    jbe up_ok
    mov al, 120
up_ok:
    mov [speed], al
no_up:
    cmp byte [spacekey], 0
    je no_brake
    mov al, [speed]
    sub al, 5
    jnc brake_ok
    xor al, al
brake_ok:
    mov [speed], al
no_brake:
    cmp byte [downkey], 0
    je no_rev
    cmp byte [speed], 0
    jne no_rev
    cmp word [dist], 0
    je no_rev
    dec word [dist]
    cmp word [score], 0
    je no_rev
    dec word [score]
no_rev:

    mov al, [speed]
    cmp al, 0
    je dashes_done
    shr al, 5
    inc al
    add [lane], al
    and byte [lane], 7
dashes_done:

    mov al, [speed]
    xor ah, ah
    add [distacc], ax
dist_loop:
    cmp word [distacc], 50
    jb dist_done
    sub word [distacc], 50
    inc word [dist]
    inc word [score]
    jmp dist_loop
dist_done:
    cmp word [dist], 1000
    jb level_going
    mov word [dist], 1000
    mov byte [state], 1
    jmp upd_end
level_going:

    inc byte [timecnt]
    cmp byte [timecnt], 9
    jb time_done
    mov byte [timecnt], 0
    dec word [timeleft]
    jnz time_done
    mov byte [state], 2
    jmp upd_end
time_done:

    cmp byte [speed], 0
    je fuel_done
    inc byte [fuelcnt]
    cmp byte [fuelcnt], 10
    jb fuel_done
    mov byte [fuelcnt], 0
    dec word [fuel]
    jnz fuel_done
    mov byte [state], 3
    jmp upd_end
fuel_done:


    xor si, si
car_loop:
    cmp byte [crash], 0
    jne car_next
    mov al, [speed]
    shr al, 6
    inc al
    add [cary+si], al
    cmp byte [cary+si], 180
    jb car_move_done
    mov byte [cary+si], 93
    mov bl, [patindex]
    xor bh, bh
    mov al, [lanepat+bx]
    mov [carlane+si], al
    mov byte [carhit+si], 0
    inc bl
    cmp bl, 6
    jb pat_ok
    xor bl, bl
pat_ok:
    mov [patindex], bl
car_move_done:
    cmp byte [cary+si], 158
    jb car_next
    cmp byte [carhit+si], 0
    jne car_next
    mov al, [carlane+si]
    cmp al, [lanenum]
    jne car_next
    mov byte [speed], 0
    mov byte [crash], 27
    mov byte [carhit+si], 1
    sub word [score], 50
    jnc car_next
    mov word [score], 0
car_next:
    inc si
    cmp si, 3
    jne car_loop

upd_end:
    pop si
    pop bx
    pop ax
    ret



car_shift:
    push bx
    push cx
    push dx
    sub ax, 53
    shl ax, 1
    xor dx, dx
    mov cx, 3
    div cx
    mov cx, ax
    mov al, [cs:lanenum]
    sub al, bl
    cbw
    imul cx
    pop dx
    pop cx
    pop bx
    ret

draw_traffic:
    push ax
    push bx
    push dx
    push si
    xor si, si
traffic_loop:
    mov bl, [carlane+si]
    cmp bl, 0
    je traffic_next
    xor dh, dh
    mov dl, [cary+si]
    mov ax, dx
    call car_shift
    mov bx, ax
    mov al, [carcolor+si]
    mov [curcolor], al
    call draw_car
traffic_next:
    inc si
    cmp si, 3
    jne traffic_loop
    pop si
    pop dx
    pop bx
    pop ax
    ret


draw_car:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, dx
    sub ax, 53
    mov cx, 3
    push dx
    xor dx, dx
    div cx
    pop dx
    mov [cw], ax
    mov cx, ax
    shr cx, 1
    mov si, ax
    shr si, 3
    add cx, si
    mov [chh], cx
    mov si, 160
    add si, bx
    mov ax, [cw]
    shr ax, 1
    sub si, ax
    cmp si, 0
    jl car_exit
    mov ax, si
    add ax, [cw]
    cmp ax, 319
    jg car_exit
    mov di, dx
    sub di, [chh]
    mov ax, di
    shl di, 6
    shl ax, 8
    add di, ax
    add di, si
    mov si, di
    mov bx, [cw]
    mov dx, [chh]
    mov al, [curcolor]
    call draw_rect
    mov ax, [cw]
    shr ax, 3
    mov di, si
    add di, 320
    add di, ax
    shl ax, 1
    mov bx, [cw]
    sub bx, ax
    mov dx, [chh]
    shr dx, 1
    mov al, 00h
    call draw_rect
    mov ax, [chh]
    shr ax, 1
    add ax, 2
    mov di, ax
    shl di, 6
    shl ax, 8
    add di, ax
    add di, si
    inc di
    mov bx, [cw]
    shr bx, 3
    inc bx
    mov dx, [chh]
    shr dx, 2
    mov al, 04h
    call draw_rect
    mov ax, [cw]
    sub ax, bx
    sub ax, 2
    add di, ax
    call draw_rect
car_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret



draw_number:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov si, cx
    mov [numcolor], bl
    mov bx, 10
num_div:
    xor dx, dx
    div bx
    push dx
    loop num_div
    mov cx, si
num_draw:
    pop ax
    add al, '0'
    mov bl, [numcolor]
    call draw_digit
    add di, 8
    loop num_draw
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


draw_digit:
    push ax
    push cx
    push dx
    push si
    push di
    push ds
    push es
    xor ah, ah
    shl ax, 3
    mov si, [fontoff]
    add si, ax
    mov dx, [bufseg]
    mov ax, [fontseg]
    mov ds, ax
    mov es, dx
    mov dx, 8
dg_row:
    lodsb
    mov cx, 8
dg_col:
    shl al, 1
    jnc dg_skip
    mov [es:di], bl
dg_skip:
    inc di
    loop dg_col
    add di, 320-8
    dec dx
    jnz dg_row
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret


draw_string:
    push ax
    push cx
    push si
    push di
str_loop:
    lodsb
    call draw_digit
    add di, 8
    loop str_loop
    pop di
    pop si
    pop cx
    pop ax
    ret

draw_numbers:
    push ax
    push bx
    push cx
    push di
    mov di, 10*8
    mov ax, [dist]
    mov cx, 4
    mov bl, 0fh
    call draw_number
    mov di, 1*2560+11*8
    mov ax, [score]
    mov cx, 4
    mov bl, 0eh
    call draw_number
    mov di, 22*2560+14*8
    xor ah, ah
    mov al, [speed]
    mov cx, 3
    mov bl, 0eh
    call draw_number
    pop di
    pop cx
    pop bx
    pop ax
    ret

show_message:
    mov di, 85*320+60
    mov bx, 200
    mov dx, 40
    mov al, 0
    call draw_rect
    call present
    mov al, [state]
    cmp al, 1
    jne msg2
    mov dl, 12
    mov cx, 15
    mov bp, text_win
    jmp msg_show
msg2:
    cmp al, 2
    jne msg3
    mov dl, 14
    mov cx, 11
    mov bp, text_timeup
    jmp msg_show
msg3:
    mov dl, 14
    mov cx, 12
    mov bp, text_nofuel
msg_show:
    mov dh, 11
    mov bl, 0eh
    call draw_text
    mov dh, 13
    mov dl, 11
    mov bl, 0fh
    mov bp, text_esc
    mov cx, 17
    call draw_text
    ret



lane_shift:
    push bx
    push cx
    push dx
    sub ax, 53
    shl ax, 1
    xor dx, dx
    mov cx, 3
    div cx
    mov cx, ax
    mov al, [cs:lanenum]
    sub al, 2
    cbw
    imul cx
    pop dx
    pop cx
    pop bx
    ret

draw_sky:
    push es
    push ax
    push cx
    push di
    mov ax, [bufseg]
    mov es, ax
    mov al, 09h
    cmp byte [crash], 0
    je sky_ok
    mov al, 04h
sky_ok:
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
    mov ax, [bufseg]
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
    mov ax, [bufseg]
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
    mov cx, 120
    sub cx, [timeleft]
    add di, 320
    jcxz black_done
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
black_done:
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
    mov cx, [timeleft]
    add di, 320
    jcxz yellow_done
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
yellow_done:
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
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, [bufseg]
    mov es, ax
    cld
    mov si, 93
road_row:
    mov ax, si
    call lane_shift
    add ax, 160
    mov bx, si
    sub bx, 53
    mov dx, ax
    add dx, bx
    dec dx
    sub ax, bx
    cmp ax, 0
    jge rd_l_ok
    xor ax, ax
rd_l_ok:
    cmp dx, 319
    jle rd_r_ok
    mov dx, 319
rd_r_ok:
    cmp dx, ax
    jl road_next
    mov cx, dx
    sub cx, ax
    inc cx
    mov di, si
    shl di, 6
    mov bx, si
    shl bx, 8
    add di, bx
    add di, ax
    xor al, al
    rep stosb
road_next:
    inc si
    cmp si, 200
    jne road_row
    pop di
    pop si
    pop dx
    pop cx
    pop bx
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
    mov ax, [bufseg]
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
    mov ax, [bufseg]
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
    mov ax, [bufseg]
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
    mov ax, [bufseg]
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
    mov ax, [bufseg]
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
    mov cx, [bufseg]
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
    push bp
    mov si, di
    mov ax, [bufseg]
    mov es, ax

    mov al, [lane]
    xor ah, ah
    mov bp, ax
    mov bx, 93
lane_row:
    mov ax, bx
    sub ax, bp
    test ax, 4
    jnz lane_skip

    mov ax, bx
    call lane_shift
    add ax, si
    mov dx, ax

    mov ax, bx
    sub ax, 53
    push dx
    xor dx, dx
    div cx
    pop dx

    mov di, bx
    shl di, 6
    push ax
    mov ax, bx
    shl ax, 8
    add di, ax
    pop ax

    push dx
    sub dx, ax
    cmp dx, 0
    jl lane_noleft
    cmp dx, 318
    jg lane_noleft
    push di
    add di, dx
    mov word [es:di], 0f0fh
    pop di
lane_noleft:
    pop dx
    add dx, ax
    cmp dx, 0
    jl lane_skip
    cmp dx, 318
    jg lane_skip
    add di, dx
    mov word [es:di], 0f0fh
lane_skip:
    inc bx
    cmp bx, 145
    jne lane_row
    pop bp
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
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
    mov bx, [fuel]
    mov dx, 6
    mov al, 0ah
    cmp word [fuel], 14
    jae fuel_ok
    mov al, 04h
fuel_ok:
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
    mov cx, 4
    call draw_text
    mov dh, 0
    mov dl, 15
    mov bl, 0fh
    mov bp, text_dist2
    mov cx, 8
    call draw_text
    mov dh, 1
    mov dl, 5
    mov bl, 0eh
    mov bp, text_score
    mov cx, 5
    call draw_text
    mov dh, 1
    mov dl, 0
    mov bl, 0fh
    mov bp, text_time
    mov cx, 4
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
    mov ax, [bufseg]
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
clearscr:
    push es
    push di
    push cx
    push ax

    mov ah, al
    mov cx, 0A000h
    mov es, cx
    xor di, di
    mov cx, 32000
    cld
    rep stosw

    pop ax
    pop cx
    pop di
    pop es
    ret
save_text:
    push ds
    push es
    push si
    push di
    push cx
    push ax

    mov ax, [textseg]
    mov es, ax
    mov ax, 0xa000
    mov ds, ax
    xor si, si
    xor di, di
    mov cx, 32000
    cld
    rep movsw

    pop ax
    pop cx
    pop di
    pop si
    pop es
    pop ds
    ret
overlay_text:
    push ds
    push es
    push si
    push di
    push cx
    push ax

    mov ax, [bufseg]
    mov es, ax
    mov ax, [textseg]
    mov ds, ax
    mov si, di
    cld
ov_loop:
    lodsb
    test al, al
    jz ov_skip
    mov [es:di], al
ov_skip:
    inc di
    loop ov_loop

    pop ax
    pop cx
    pop di
    pop si
    pop es
    pop ds
    ret
present:
    push ds
    push es
    push si
    push di
    push cx
    push dx
    push ax

    mov dx, 3DAh
wait_end:
    in al, dx
    test al, 8
    jnz wait_end
wait_start:
    in al, dx
    test al, 8
    jz wait_start

    mov ax, [bufseg]
    mov ds, ax
    mov ax, 0xa000
    mov es, ax
    xor si, si
    xor di, di
    mov cx, 32000
    cld
    rep movsw

    pop ax
    pop dx
    pop cx
    pop di
    pop si
    pop es
    pop ds
    ret

text_dist: db 'DIST'
text_dist2: db '/ 1000 m'
text_score: db 'SCORE'
text_time: db 'Time'
text_kmh: db 'km/h'
text_fuel: db 'FUEL'
text_e: db 'E'
text_f: db 'F'
text_win: db 'LEVEL COMPLETE!'
text_timeup: db 'TIME IS UP!'
text_nofuel: db 'OUT OF FUEL!'
text_esc: db 'Press ESC to exit'
text_crash: db 'CRASH!'

ticks: db 0
lastticks: db 0
speed: db 0
upkey: db 0
spacekey: db 0
downkey: db 0
quit: db 0
state: db 0
oldisr: dd 0
oldisr1: dd 0
lane: db 0
next: db 0
lanenum: db 2

dist: dw 0
distacc: dw 0
score: dw 0
timeleft: dw 120
timecnt: db 0
fuel: dw 54
fuelcnt: db 0

cary: db 93, 122, 151
carlane: db 2, 3, 1
carhit: db 0, 0, 0
patindex: db 0
lanepat: db 2, 1, 3, 3, 1, 2

numcolor: db 0
crash: db 0
curcolor: db 0
carcolor: db 3, 5, 0Eh
cw: dw 0
chh: dw 0
fontoff: dw 0
fontseg: dw 0
bufseg:  dw 0
textseg: dw 0