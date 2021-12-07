; print the char in AL at gs:edi
; edi always point to next char to be print
			DispAL:

					mov 	ah, 0ch ; black background , red char
					mov 	[gs:edi], ax
					add 	 edi, 2
					ret

;print the char from [ds:ebx] to [ds:ebx + cx] at [gs:edi] 		
			DispString:
					push     ebx
					push 	 cx
                    push     ax
			DispStringStart:		
					mov 	byte al, [ds : ebx]
					call 	   DispAL
					add 	  ebx, 1
					sub  	   cx, 1
					cmp 	  cx, 0
					jne 	   DispStringStart
                    pop     ax
					pop 	cx
					pop 	ebx
					ret

;print the int from [ds:ebx] to [ds:ebx + cx] at [gs:edi] 		
			DispInt:
					push     ebx
					push 	 cx
                    push     ax
			DispIntStart:		
					mov 	byte al, [ds : ebx]
					call 	   DispAL_As_Int
					add 	  ebx, 1
					sub  	   cx, 1
					cmp 	  cx, 0
					jne 	   DispIntStart
					pop     ax
                    pop 	cx
					pop 	ebx
					ret


;PrintReturn  print a enter to change line
			PrintReturn:
					push 	eax
					push 	ebx
					mov 	eax, edi
					mov 	bl, 160
					div 	  bl
					and 	 eax, 0ffh
					inc 	  eax
					mov 	bl, 160
					mul 	 bl
					mov 	edi, eax
					pop 	 ebx
					pop 	 eax
					ret

				

;Disply AL as Number (defual is char)
			DispAL_As_Int:
					mov 	ah, 0ch ; black background , red char
					push   	cx
					push 	ax
					mov    cx, 02h
					shr 	al, 4
			START_CHANGE:
					cmp 	al, 0ah
					jl 			NUMBER1
					add al, 037h
					jmp PRINT
			NUMBER1:
					add al, 030h
			PRINT:
					mov 	[gs:edi], ax
					add 	 edi, 2
					sub 	 cx, 1
					cmp 	cx, 0
					jne  	 ANOTHER
					jmp     END
			ANOTHER:
					pop 	ax
					and 	al, 0fh
					jmp 	START_CHANGE
			END:
					pop  	cx			 
					ret

            CLEAR:
            ;clear the screen
            mov   edi, 0
            mov     al, 0
            CLOOP:    
            call    DispAL
            cmp     edi, (80*25)*2
            jl          CLOOP
            xor     edi, edi
            ret
