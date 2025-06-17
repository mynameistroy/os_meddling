[org 0x7c00]
bits 16
    global _start

    section .text
_start:
    call clrscr     ; clear the screen
    xor bx, bx      ; zero bx
    xor ax, ax      ; zero ax
    xor cx, cx      ; zero cx
    mov ax, video   ; put the address for video memory in ax
    mov es, ax      ; setup ES to point to the base of video memory

; write hello world over the entire screen
loop:
    lea si, msg             ; load the address of the string 
    add si, cx              ; add the offset into the string to copy
    mov al, [si]            ; copy character into al
    mov byte [es:bx], al    ; set character byte
    mov byte [es:bx+1], 0x7 ; set attribute byte
    add bx, 2               ; add 2 to offset to the next char/attr pair
    inc cx                  ; increment cx
    cmp al, 0               ; check if at end of string
    jne eos                 ; skip zero if not at EOS
    xor cx, cx              ; zero cx to start at beginning of string
eos:
    cmp bx, video_len       ; are we at the end of video memory
    jne loop                ; if not, goto beginning of loop

; halt here
end:
    jmp end


; clear the screen
clrscr:
    xor bx, bx      ; clear bx
    mov ax, video   ; set ax to base of video memory
    mov es, ax      ; load video memory addess into ES
clrscr_loop:
    mov byte [es:bx], ' '       ; write space
    mov byte [es:bx + 1], 0x7   ; write attribute
    add bx, 2                   ; increment to next char/attr pair
    cmp bx, video_len           ; check if at the end of video memory
    jne clrscr_loop             ; if not equal loop back
    ret                         ; return 


    section .data

video       equ 0xB800
video_len   equ 4000
msg:
    db "Hello World",0

; setup empty bytes to pad to 510 + signature
times 434 - ($ - $$) db 0
dw 0xaa55
