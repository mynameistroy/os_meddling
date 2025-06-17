[BITS 16]
[ORG 0x7c00]

start:
    cli             ; disable interrupts
    xor ax, ax      ; clear ax
    mov ds, ax      ; set DS to 0
    mov es, ax      ; set ES to 0
    mov ss, ax      ; set SS to 0
    mov sp, 0x7c00  ; set stack pointer to 0x7c00

    lgdt [gdt_desc]         ; load GDT
    
    ; enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    
    mov eax, cr0            ; get cr0 value
    or eax, 1               ; set bit 0 to enable protected mode
    mov cr0, eax            ; set cr0 register

    jmp CODE_SEG:protected_mode  ; clear pipeline and jump to protected mode

[BITS 32]

protected_mode:
    mov ax, DATA_SEG
    mov ds, ax          ; set segment registers to 0
    mov es, ax      
    mov fs, ax
    mov gs, ax
    mov ss, ax          ; set stack segment
    mov esp, 0x90000    ; set stack address

    call clrscr     ; clear the screen
    xor ebx, ebx    ; zero bx
    xor eax, eax    ; zero ax
    xor ecx, ecx    ; zero cx
 
; write hello world over the entire screen
loop:
    lea esi, msg                        ; load the address of the string 
    add esi, ecx                        ; add the offset into the string to copy
    mov eax, [esi]                      ; copy character into al
    mov byte [VIDEO_MEM + ebx], al      ; set character byte
    mov byte [VIDEO_MEM + ebx + 1], 0x7 ; set attribute byte
    add ebx, 2                          ; add 2 to offset to the next char/attr pair
    inc ecx                             ; increment cx
    cmp al, 0                           ; check if at end of string
    jne eos                             ; skip zero if not at EOS
    xor ecx, ecx                        ; zero cx to start at beginning of string
eos:
    cmp ebx, VIDEO_MEM_LEN  ; are we at the end of video memory
    jne loop                ; if not, goto beginning of loop

; halt here
end:
    jmp end

; clear the screen
clrscr:
    xor ebx, ebx        ; clear bx
clrscr_loop:
    mov byte [VIDEO_MEM + ebx], ' '     ; write space
    mov byte [VIDEO_MEM + ebx + 1], 0x7 ; write attribute
    add ebx, 2                          ; increment to next char/attr pair
    cmp ebx, VIDEO_MEM_LEN              ; check if at the end of video memory
    jne clrscr_loop                     ; if not equal loop back
    ret                                 ; return 

; Global Descriptor Table
gdt_start:
; First segment is always a Null Segment
gdt_null:
    dq 0
; Code Segment
gdt_code:
    dw 0xFFFF       ; sets first 16 bits of the limiter (4GB)
    dw 0            ; sets the first 16 bits of the base address
    db 0            ; bits 16-23 of base address
    db 10011010b    ; set descripter properties
    db 11001111b
    db 0            ; bits 24-31 of base address
; Data Segment
gdt_data:
    dw 0xFFFF       ; sets first 16 bits of the limiter (4GB)
    dw 0            ; sets the first 16 bits of the base address
    db 0            ; bits 16-23 of base address
    db 10010010b    ; set descriptor properties
    db 11001111b
    db 0            ; bits 24-31 of base address
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1  ; size of GDT in bytes
    dd gdt_start                ; GDT address

CODE_SEG        equ gdt_code - gdt_start
DATA_SEG        equ gdt_data - gdt_start
VIDEO_MEM       equ 0xB8000
VIDEO_MEM_LEN   equ 4000
msg:
    db "Hello World",0

; setup empty bytes to pad to 510 + signature
times 510 - ($ - $$) db 0
dw 0xaa55
