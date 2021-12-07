[section .text]

extern out_byte
extern in_byte
extern finish_int_m
extern finish_int_s


; use for out a byte to port       out_byte(port, byte)
out_byte:
                push    ebp
                mov     ebp, esp
                push     edx
                mov     dword edx, [ebp+8]
                mov     dword eax, [ebp+12]
                out       dx, al
                nop
                nop
                nop
                pop        edx
                pop        ebp
                ret

;use for in a byte from port       in_byte(port)
in_byte:
                push    ebp
                mov     ebp, esp
                push     edx
                mov     dword edx, [ebp+8]
                xor       eax, eax
                in         al, dx
                nop
                nop
                nop
                pop     edx
                pop     ebp
                ret

finish_int_m:
                mov     al, 20h 
                out      20h, al
                ret

finish_int_s:
                 mov     al, 20h 
                 out       0a0h, al
                 ret
                
