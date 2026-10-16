org 0x7C00 ; bios loaded here, org -> starting point basically
bits 16 ; 16 bit mode for compatability backwards

%define ENDL 0x0D, 0x0A ; NASM macro for end line char

; Bootloader primary purpose is to use the 512 bytes we have
; access to and load the rest of the OS from there.
; This OS is currently living on a mock floppy disk
; as a result, below is some FAT12 stuff to get a filesystem
;
; FAT12 HEADER
; https://wiki.osdev.org/FAT#Boot_Record
;

; L17/18 refer to skipping all the data listed here, these are headers for FAT12
; bdb -> Bios Parameter Block
jmp short start
nop

bdb_oem:                        db 'MSWIN4.1'               ; 8b
bdb_bytes_per_sector:           dw 512
bdb_sectors_per_cluster:        db 1
bdb_reserved_sectors:           dw 1
bdb_fat_count:                  db 2
bdb_dir_entires_count:          dw 0E0h
bdb_total_sectors:              dw 2880                     ; 2880 * 512 = 1.44MB
bdb_media_desc_type:            db 0F0h                     ; ~3.5'' floppy
bdb_sectors_per_fat:            dw 9                        ; 9 sectors/fat
bdb_sectors_per_track:          dw 18
bdb_heads:                      dw 2
bdb_hidden_sectors:             dd 0
bdb_large_sector_counter:       dd 0

; EXTENDED BOOT REC
edr_drive_num:                  db 0                        ; 0x00 floppy, 0x80 hdd, apparently useless
                                db 0                        ; reserved
ebr_signature:                  db 29h
ebr_volume_id:                  db 18h, 36h, 50h, 72h       ; serial num, value meaningless, random num
ebr_volume_label:               db 'Cloudy OS**'            ; 11 bytes, padded with *
ebr_system_id:                  db 'FAT12   '               ; 8 bytes, padded with spaces

;
; BDB EBR CODE
;



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
    mov si, msg_test
    call puts
    hlt ; terminate

.halt:
    jmp .halt


msg_hello: db 'Hello World', ENDL, 0
msg_test: db 'Testing does this work!', ENDL, 0


times 510-($-$$) db 0 ; ($-$$ length of program in bytes
dw 0AA55h
