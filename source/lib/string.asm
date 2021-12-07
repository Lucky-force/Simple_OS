SelectorVideo       EQU         8

[section .text]

extern VideoPointer

global  memcpy
global print
global dispal
global clean
global printReturn
global back_space
global is_top

; use for memory copy    memcpy(dst*, src*, size)
memcpy:
                push    ebp
                mov     ebp, esp
                push    ebx
                push    ecx
                mov     dword ecx, [ebp + 16]
                mov     dword eax, [ebp + 12]
                mov     dword ebx, [ebp + 8]
            MLOOP:
                mov     byte dl, [ds:eax]
                mov     byte [ds:ebx], dl
                inc       eax
                inc       ebx
                dec      ecx
                cmp     ecx, 0
                jg         MLOOP
                pop       ecx
                pop       ebx
                pop       ebp
                ret

;use for print      print(char*, num)
print:
                push    ebp
                mov     ebp, esp
                push     ebx
                push     ecx
                push     edi
                mov     ax, SelectorVideo
                mov     gs, ax
                mov     dword edi, [VideoPointer]
                mov     eax, [ebp+16]
                mov     ecx, [ebp + 12]
                mov     ebx, [ebp + 8]
                shl       eax, 8
            PLOOP:
                mov     byte al, [ebx]
                mov     word [gs:edi], ax
                add      edi, 2
                inc       ebx
                dec      ecx
                cmp     ecx, 0
                jg         PLOOP
                mov     dword [VideoPointer], edi
                pop     edi
                pop     ecx
                pop     ebx
                pop     ebp
                ret

; print al to screen
dispal:
                push    ebx
                push    edi
                mov     bx, SelectorVideo
                mov     gs, bx
                mov     dword edi, [VideoPointer]
                mov     ah, 0ch
                mov     word [gs:edi], ax
                add       edi, 2
                mov     dword [VideoPointer], edi
                pop      edi
                pop      ebx
                ret

clean:  
                push    edi
                mov     ax, SelectorVideo
                mov     gs, ax
                xor       edi, edi
            LOOPC:
                mov     word [gs:edi], 0
                inc        edi
                cmp      edi, (80*25)*2
                jle         LOOPC
                mov     dword [VideoPointer], 0
                pop        edi
                ret

printReturn:
					push 	ebx
					mov 	dword eax, [VideoPointer]
					mov 	bl, 160
					div 	  bl
					and 	 eax, 0ffh
					inc 	  eax
					mov 	bl, 160
					mul 	 bl
					mov 	dword [VideoPointer], eax
					pop 	 ebx
					ret

back_space:
                    push    ebx
                    mov     bx, SelectorVideo
                    mov     gs, bx
                    mov     dword ebx, [VideoPointer]
                    sub      ebx, 2
                    mov     word [gs:ebx], 0          
                    mov     dword [VideoPointer], ebx
                    pop       ebx
                    ret

is_top:
                    push     ebx
                    mov     ebx, [VideoPointer]
                    cmp     ebx, 0
                    je          IsTop 
                    mov     eax, 0
                    jmp      IsEnd
            IsTop:
                    mov     eax, 1
                   
            IsEnd:
                    pop      ebx
                    ret
                    

                