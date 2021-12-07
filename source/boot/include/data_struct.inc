;=====================================================
;                                     Defined Symbols
;=====================================================



;   usage: Descriptor Base, Limit, Attr
;               Base: dd
;               Limit: dd(lower 20bits are used)
;               Attr: dw(lower 4bits of high byte are not used)
%macro Descriptor 3
        dw  %2 & 0ffffh
        dw  %1 & 0ffffh
        db (%1 >> 16) & 0ffh
        dw %3 + ((%2 >> 8) & 0f00h)
        db (%1 >> 24) & 0ffh
%endmacro   ;8 bytes GDT Descriptor (for code segment or data segment)

; usage : Gate  Selector,  Offset,  DCount,  Attr
;                  Selector: dw
;                   Offset: dd
;                   DCount: db (number of Param)
;                   Attr: db (similar with Descriptor)
%macro Gate 4
        dw %2 & 0ffffh
        dw %1 & 0ffffh
        db %3 & 01fh
        db %4 & 0ffh
        dw (%2>>16) & 0ffffh
%endmacro   ;8 bytes Gate Descriptor (for gate)


; Type of the descriptor
DA_32        EQU    4000h    ; means this segment is 32bits (default is 16bits)

;limit range
DA_LIMIT_4K     EQU     8000h  ;G = 1

; Privilege level
DA_DPL0   EQU    00h        ; DPL = 0
DA_DPL1   EQU    20h        ; DPL = 1
DA_DPL2   EQU    40h        ; DPL = 2
DA_DPL3   EQU    60h        ; DPL = 3

; Type of the segment
DA_DR       EQU    90h        ; Data Read  (the exsit data segment which can be read)
DA_DRW    EQU    92h        ; Data Read Write
DA_DRWA  EQU    93h        ; Data Read Write Accessed(has been visited)
DA_CX        EQU   98h         ; Code X (the exsit code segment which can be run)
DA_CXR      EQU   9ah         ; Code X Read
DA_CXCO   EQU   9ch         ; Code X Conforming
DA_CXCOR EQU   9eh         ; Code X Conforming Read

; Syetem segment Descriptor
DA_LDT      EQU   82h         ;This segment is a Local Descriptor Table
DA_TaskGate EQU  85h        ;This segment is a TaskGate
DA_386TSS   EQU  89h         ;This segment is a TSS
DA_386CGate EQU 8ch        ;This segment is a CallGate
DA_386IGate  EQU 8eh        ; This segment is a IntereputGate
DA_386TGate  EQU 8fh        ; This segment is a TrapGate


; Page Directory Entry and Page Table Entry
PG_P          EQU           1h     ; this page or page table is exsit in physical memory
PG_RW       EQU           2h     ; can be read and write (default is can only be read)
PG_US        EQU           4h     ; the privilage of this page or page table (default 0 is system level)
PG_PWT     EQU           8h     ; ????????
PG_PCD     EQU           10h   ; ?????????
PG_A           EQU           20h  ; this page or page table has be visited (default is 0 , not be visited)
PG_D           EQU           40h  ; this page or page table has be written (default is 0 , not be written)
PG_PS          EQU           80h  ; the size of page (default is 0 , 4K per page)
PG_PAT        EQU           80h ; ????
PG_G            EQU           100h ; global page 
