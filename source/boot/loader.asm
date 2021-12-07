org 0a000h
%include "data_struct.inc"
LABEL_START:
jmp     LABEL_BEGIN

PageDirBase         equ         200000h
PageTblBase         equ          201000h
[SECTION .gdt]
LABEL_GDT:                                 Descriptor                    0,                      0,                         0
LABEL_DESC_VIDEO:                 Descriptor         0b8000h,               0fffffh,                DA_DRW + DA_DPL3
LABEL_DESC_FLAT_C:               Descriptor                    0,                0fffffh,               DA_32 + DA_CXR + DA_LIMIT_4K
LABEL_DESC_FLAT_RW:            Descriptor                    0,                 0fffffh,               DA_32 + DA_DRW + DA_LIMIT_4K
LABEL_DESC_PAGE_DIR:          Descriptor  PageDirBase,                   4095,              DA_DRW
LABEL_DESC_PAGE_TBL:          Descriptor  PageTblBase,             4096*8-1,              DA_DRW   ; change it when use other mechine

GdtLen          EQU             $ - LABEL_GDT
GdtPtr           dw                GdtLen -1
                      dd                    0


SelectorVideo           EQU                 LABEL_DESC_VIDEO - LABEL_GDT
SelectorFlatCode     EQU                 LABEL_DESC_FLAT_C - LABEL_GDT
SelectorFlatData      EQU                 LABEL_DESC_FLAT_RW - LABEL_GDT
SelectorPageDir       EQU                LABEL_DESC_PAGE_DIR - LABEL_GDT
SelectorPageTbl       EQU                 LABEL_DESC_PAGE_TBL - LABEL_GDT

MEMData:            times   250    db   0
MEMDataTimes:   dw       0
MEMSize:              dd       0

[SECTION    .s16]
[BITS   16]

LABEL_BEGIN:

        ;get memory information
        xor     eax, eax
        mov     es, ax   ; es = 0
        mov     ds, ax
        mov     si, 0
		nop
		mov 	ebx, 0
		; will put data in es:di , in real mode 
		mov 	di, MEMData
		Gloop:		
		mov 	edx, 0534d4150h
		mov 	ecx, 20
		mov 	eax, 0e820h
	    int 	 	15h
		add 	 di, 20
        add      si, 1
		cmp 	ebx, 0
        mov     [ds:MEMDataTimes], si
		jne		  Gloop




;load GDT
    xor     eax, eax
    ;mov   ax, cs
    ;shl      eax, 4
  
    add     eax, LABEL_GDT
    mov    dword [GdtPtr + 2], eax
    lgdt    [GdtPtr]

; shut down inerput
    cli
; open adreess line 20
	in 		al, 92h
	or 		al, 00000010b
	out 	92h, al
;preper for changing to protect mode
	mov 	eax, cr0
	or 		   eax, 1
	mov 	cr0, eax

    jmp        dword  SelectorFlatCode:LABEL_CODE32



[SECTION    .s32]
[BITS   32]
LABEL_CODE32:
    mov     ax, SelectorVideo
    mov     gs, ax
    call      CLEAR
    mov     ax,  SelectorFlatData
    mov     ds, ax
    mov     ss, ax
    ; Get the memory infotmation
    push     edi
    mov     ebx, MEMData
    mov     ax, 7
L:
    mov     si, 5
P:
    mov     cx, 4
    call      DispInt
    push    ax
    mov     al, 20h
    call      DispAL
    pop      ax
    add     ebx, 4
    sub     si, 1
    cmp     si, 0
    jne         P
    call     PrintReturn
   ; add      ebx, 20
    sub       ax, 1
    cmp     ax, 0
    jg        L
    mov     ebx, MEMData
    xor     edx, edx
    xor     eax, eax
    mov     si, [ds:MEMDataTimes]
    AGAIN:
    add      ebx, 16
    mov     cl, [ds:ebx]
    cmp     cl, 1
    jne       MLAST 
    sub      ebx, 5
    ;length
    mov     al, [ds:ebx]
    shl       eax, 8
    sub      ebx, 1
    mov     al, [ds:ebx]
    shl       eax, 8
    sub      ebx, 1
    mov     al, [ds:ebx]
    shl        eax, 8
    sub       ebx, 1
    mov     al, [ds:ebx]
    ;base
    sub     ebx, 5
    mov     dl, [ds:ebx]
    shl       edx, 8
    sub       ebx, 1
    mov     dl, [ds:ebx]
    shl        edx, 8
    sub       ebx, 1
    mov     dl, [ds:ebx]
    shl        edx, 8
    sub        ebx, 1
    mov     dl, [ds:ebx]
    add       edx, eax
    add       ebx, 20
    jmp     LLAST

MLAST:
    add        ebx, 4
    jmp        LLAST
LLAST:
    sub         si, 1
    cmp        si, 0
    jne         AGAIN
    ; the sum of the memory will be put into ds:MEMSize, use for paging
    mov       dword [ds:MEMSize], edx
    pop         edi ;0xa26a
    ;start the page mode, the size of memory are in edx now
    ; first initial the GDT of PageTble (the PageDir has already initialed)
    xor      edx, edx
    mov    dword eax, [ds:MEMSize]
    mov     ebx, 1000h
    div       ebx
    mov     ecx, eax
    push    ecx

    xor     edx, edx
    mov    dword eax, [ds:MEMSize]
    mov     ebx, 400000h
    div       ebx
    mov     ecx, eax
    cmp     edx, 0
    je         PCOUNTINUE
    add     ecx, 1
    push    ecx
PCOUNTINUE:
; now ecx stored how many page table can be initialed
; initial the page directory
    pop     ecx
    mov     ax, SelectorPageDir
    mov     es, ax
    xor       edi, edi
    xor       eax, eax
    mov     eax, PageTblBase + PG_P + PG_US + PG_RW
PDLOOP:
    stosd
    add       eax, 4096 ;0xa2c0
    loop      PDLOOP

; initial page table
    pop      ecx
    mov     ax, SelectorPageTbl
    mov     es, ax
    xor        edi, edi
    xor        eax, eax
    mov      eax, PG_P + PG_US + PG_RW
PTLOOP:
    stosd
    add        eax, 4096
    loop        PTLOOP

    mov       eax, PageDirBase ; 0xa2c7
    mov       cr3, eax
    mov       eax, cr0
    or           eax, 80000000h
    mov       cr0, eax

; paging finished
; this paging may have some bug in differnt machines
; try to debug it and change it, it's easy 


; going to mov kernel to another place
; now the kernel in memory is a ELF file
; we should analize it and mov it's main part to a suitable place

; kernel file start at 0xb000  
    xor      eax, eax ;0xa2dc
    mov     edx, 0b000h
    add      edx, 31
    mov     cx, 3
KLOOP:
    mov     byte al, [ds:edx]
    shl       eax, 8
    dec      edx
    dec      cx
    cmp     cx, 0
    jne       KLOOP
    mov     byte al, [ds:edx]
    dec      edx
    push    eax ; offset of program header in file
    add     edx, 18
    xor     eax, eax
    mov     al, byte [ds:edx]
    shl     eax, 8
    dec     edx
    mov     al, byte [ds:edx]
    dec      eax ; the last one is no use, don't load it, it's all zero, just some information
    push    eax ; num of program headers
    ;we don't need the length of per program header
    ; we treat it as default 0x20
    ; if something change, just change the loop
    mov     ebp, esp ; [ebp] = phonum      [ebp+4] = phoff
    mov     edx, 0b000h

  
    add      dword edx, [ebp+4]
READTOMEM:
    xor       eax, eax
    add      edx, 7
    mov     cx, 3
LOOP1:
    mov      byte al, [ds:edx]
    shl        eax, 8
    dec       edx
    dec       cx
    cmp      cx, 0
    jne        LOOP1
    mov      byte al, [ds:edx]
    dec       edx
; now the offset in file is in eax

    add        edx, 8
    xor        ebx, ebx
    mov       cx, 3
LOOP2:
    mov     byte bl, [ds:edx]
    shl        ebx, 8
    dec       edx
    dec       cx
    cmp      cx, 0
    jne        LOOP2
    mov     byte bl, [ds:edx]
    dec       edx
; now the offset in memory is in ebx

    add      edx, 12
    xor       ecx, ecx
    mov     si, 3
LOOP3:
    mov     byte cl, [ds:edx]
    shl        ecx, 8
    dec        edx
    dec        si
    cmp       si, 0
    jne         LOOP3 
    mov     byte cl, [ds:edx]
    dec        edx
; now   the length of segment is in ecx

    add       edx, 17 ; point to next program header
    push      edx
    add       eax, 0b000h  ; now eax point to the start of segment
COPY: 
    mov       byte dl, [ds:eax]
    mov       byte [ds:ebx], dl
    inc        eax
    inc        ebx
    dec         ecx
    cmp        ecx, 0
    jne         COPY

    pop        edx ; 0xa388
    dec        dword [ebp]
    cmp       dword [ebp], 0
    jne         READTOMEM

; the kernel has being loaded into the proper place now







    jmp     SelectorFlatCode:30400h



















    
    

	jmp		$



%include "lib.inc"



times 512 db 0
