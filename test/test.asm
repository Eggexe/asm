org 0x7C00
bits 16

mov ah, 0x0e                    ; init teletype output
mov al, 65                      ; letter A
int 0x10                        ; bios interrupt 0x10
jmp lower

upper:
        inc al
        sub al, 32
        int 0x10
        cmp al, 90
        je exit
        jmp lower

lower:
        inc al
        add al, 32
        int 0x10
        cmp al, 122
        je exit
        jmp upper


loop:
        jmp lower
        je exit
        int 0x10                ; otherwise, bios int 0x10
        jmp loop

exit:
        jmp $                   ; skip

times 510-($-$$) db 0
db 0x55, 0xaa
