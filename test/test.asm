org 0x7C00
bits 16

mov ah, 0x0e                    ; init teletype output
mov al, 65                      ; letter A
int 0x10                        ; bios interrupt 0x10

loop:
        inc al                  ; increment comamnd
        cmp al, 'Z' + 1         ; if al = z + 1
        je exit                 ; jump to exit
        int 0x10                ; otherwise, bios int 0x10
        jmp loop

exit:
        jmp $                   ; skip iirc

times 510-($-$$) db 0
db 0x55, 0xaa
