org 0x7C00 ; bios loaded here, org -> starting point basically
bits 16 ; 16 bit mode for compatability backwards

%define ENDL 0x0D, 0x0A ; NASM macro for end line char

start: ; jump to main so main is still the entry point to the program, otherwise puts is treated as the start
    jmp main

; Prints a string to the string
; Params:
;   - ds:si points to string
puts:
    ; save registers to modify, pushed to stack
    push si
    push ax

.loop:
    lodsb               ; Loads next char in AL
    or al, al           ; verify if next char is null
    jz .done

    mov ah, 0x0e        ; call bios interrupt
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret

main:
    ; data seg
    mov ax, 0
    mov ds, ax
    mov es, ax

    ;stack setup
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downward

    mov si, msg_hello
    call puts

    hlt ; terminate

.halt:
    jmp .halt


msg_hello: db 'Hello World', ENDL, 0


times 510-($-$$) db 0 ; ($-$$ length of program in bytes
dw 0AA55h
