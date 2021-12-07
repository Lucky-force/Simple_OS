;==========================================
;
;     BOOT PROGRAM TO LOAD THE LOADER
;
;==========================================

; This program is used to load loader from floppy

org 07c00h
jmp short LABEL_START
nop                 ; this is neccesary, but why?
; head of fat12, to make the floppy be recognizable to linux, so that we can easily write files into the floppy
    BS_OEMName             DB     '$Limiter'             ;OEM String, must be 8 bytes
    BPB_BytesPerSec         DW    512                      ;how many bytes per sector has
    BPB_SecPerClus          DB      1                         ;how many sectors per cluster has 
    BPB_RsvdSecCnt          DW     1                         ;how many clusters a boot take
    BPB_NumFATs              DB      2                         ;how many FAT tables
    BPB_RootEntCnt           DW     224                     ;the max number of root directory file
    BPB_TotSec16               DW     2880                   ;the number of total logic sectors
    BPB_Media                   DB       0xf0                   ;media discription
    BPB_FATSz16                DW     9                        ;how many sectors a FAT table take
    BPB_SecPerTrk             DW     18                       ;how many sectors a track has
    BPB_NumHeads            DW      2                        ;the number of head
    BPB_HiddSec                 DD      0                        ;how manr hidden sectors
    BPB_TotSec32                DD      0                        ;when there are too many sectors that TotSec16 can't record,we use it to instead
    BS_DrvNum                    DB      0                        ;drive number of interput 13h
    BS_Reservedl                  DB      0                        ;not be used
    BS_BootSig                     DB      29h                    ;extend flag(29h)
    BS_VolID                        DD      0                        ;the serial nuber of volume
    BS_VolLab                      DB      'C.C._OS_FD '   ;the label of volume, must be 11 bytes
    BS_FileSysType               DB      'FAT12   '           ;type of file system, must be 8 bytes
;some defined value
    BaseOfStack                    equ                      07c00h  ; base of stack, from 07c00h ,grow up
    NumOfRootDirSec           equ                      ((224 * 32) + (512 - 1)) / 512
    StartOfRootDirSec           equ                      2 * 9 + 1
    StartOfDataSec                equ                       StartOfRootDirSec + NumOfRootDirSec
    FileName:                        db                        'LOADER  BIN'
    KernelName                     db                       'KERNEL  BIN'
    NotFoundMessage:          db                       'failed'
    FoundMessage                 db                       'loading'
    FLAG                               db                         0
    LoadAddress                    dw                         2100h
LABEL_START:
                    
                 ;initial stack
                mov     ax, cs
                mov     ss, ax
                mov     ds, ax
                mov     sp, BaseOfStack
                mov     bp, sp
                mov     ax, 0b800h
                mov     gs, ax
                mov     di, 0       ;gs:di point to video memory      0x07c76
    STARTOFLOAD:
                cmp    byte [FLAG], 1
                je          KERNELLoad
                jl           FILELoad
                jg          ENDOFBOOT
    KERNELLoad:
                mov      ecx, KernelName
                jmp        LOADING
    FILELoad:
                mov       ecx, FileName


; load loader and kernel 
; loader at 0x0a000
; kernerl at 0x0b000
    LOADING:
                ;going to load
                push    ecx
                xor       cx, cx
                mov     cx, NumOfRootDirSec ; the number of root directory's sectors
                mov     ax, 07f0h
                mov     es, ax
                mov     bx, 0         ; read root directory sectors to es : bx (0x07f00h)


                mov     ax, StartOfRootDirSec
                push     ax
                push     cx
                call       ReadToMemory  ; 0x07ca8
                ; find the first cluster of "loader     "(11bytes)
                pop        ecx              ; 0x07cab
            Find:
                mov     dword eax, [ecx]
                mov     dword edx, [es:bx]
                cmp     eax, edx
                jne       NEXT
                mov     dword eax, [ecx + 4]
                mov     dword edx, [es:bx+4]
                cmp     eax, edx
                jne       NEXT
                mov     word ax, [ecx + 8]
                mov     word dx, [es:bx+8]
                cmp     ax, dx
                jne       Find
                mov     byte al, [ecx + 10]
                mov     byte dl, [es:bx+10]
                cmp     al, dl
                jne       Find
                add      bx, 26     ; when  finished , es:bx point to cluster of this file, 2 bytes
                jmp      Continue
            NEXT:
                add     bx, 32
                cmp    bx, 32*224 ; 32 * BPB_RootEntCnt
                jg        NotFound
                jmp     Find
            NotFound:
                push     ax
                mov     ax, NotFoundMessage
                push     ax
                mov     ax, 6
                push    ax
                call      PrintString
                pop      ax
                pop      bx
                jmp       $    
                
            ; now, the es:bx point to the first cluster of file 

            Continue:
                push     ax
                mov     ax, FoundMessage
                push     ax
                mov     ax, 7
                push     ax
                call       PrintString
                pop      ax     ; 0x07d0d
            ;going to load all the clusters of file to memorty
            ; FAT1 is same with FAT2(most time) , just need to load FAT1
            ; we had find the filename , so we already know the first cluster of the file, root directory sectors have no use now, we load FAT1 to cover it
            ; but at first, we must save the first cluster of the file
                mov     si, [es:bx]  ;save the cluster number to si
                mov     bx, 0
                mov     ax, 1 ; StartOfFAT1Sec
                push     ax
                mov      ax, 9
                push      ax
                call       ReadToMemory  ; now the FAT1 has covered the root directory sectors( not all, just covered one sector )
      
                mov     bx, [LoadAddress]   ;0x07d1f
          ReadLoader:
                mov      ax, si             ; loader start at es:2100h
                call       ChangeClusterToSector
                push     ax
                mov     ax, 1
                push     ax
                call       ReadToMemory
                add       bx, 512  ;0x07d0f
                call       FindNextCluster
                cmp      si, 0ff7h
                jl           ReadLoader

                add    byte [FLAG], 1
                add     word  [LoadAddress], 1000h
                jmp      STARTOFLOAD

            ENDOFBOOT:    
                jmp      07f0h:2100h





; below are some functions to be used , we cannot write them to lib.inc and include it
; because our space is limited,
; there may be some other functions in lib.inc
; if include it, may take more space



                    

                ;a fuction to change the format of section number to track , head , and start section number, then load them to es:bx
                ;push param1 : start sector , and param2 : how many sectors to be load
                ;all of  params are 2 bytes
                ReadToMemory:

                    GetParam:
                                push     bp
                                mov      bp, sp
                                push      ax
                                push      cx
                                push      dx
                                push      di
                                mov       ax, [bp + 6]
                                push       bx
                                mov       bl, [BPB_SecPerTrk]
                                div         bl
                                inc         ah
                                mov       cl, ah
                                mov       ch, al
                                shr         ch, 1
                                mov       dh, al
                                and        dh, 1
                                pop        bx
                                mov       dl, [BS_DrvNum]    ; floppy drive number, 0 means A floppy
                    Retry:            
                                mov       ax, [bp+4]
                                mov        ah, 2
                                int         13h
                                jc           Retry    ; if failed , retry    0x07d4b
                                pop         di
                                pop         dx
                                pop         cx
                                pop         ax
                                pop         bp
                                ret           4

                PrintString:
                                ;need start address and number
                                ;fisr param is start address, second param is how manty bytes to be print
                                ; in real mode, here cs will not change, the adress will be cs:param1
                                push    bp
                                mov     bp, sp
                                push    cx
                                push    si
                                mov     si, [bp + 6]
                                mov     cx, [bp + 4]
                                mov     ah, 0ch
                    PLoop:            
                                mov     byte al, [si]
                                mov     [gs:di], ax
                                inc       si
                                add       di, 2
                                sub       cx, 1
                                cmp      cx, 0
                                jne        PLoop
                                pop       si
                                pop       cx
                                pop       bp
                                ret         4

                ChangeClusterToSector:
                    ; use this function to change Cluster number to Sector number
                    ; put the Cluster number in to ax, then it will be changed
                 ; cluster >= 2 (must! >_<)
                                sub        ax, 2
                                add        ax, StartOfDataSec
                                ret
                
                FindNextCluster:
                    ;the initial cluster is in di
                    ;get the next cluster and put it into di
                    ;FAT1 is at es:0
                    ;read 3 bytes per time
                    push   ax
                    push   bx
                    push   cx
                    push   dx
                    mov   bx, si
                    shr     bx, 1 ; div 2
                    mov    ax, bx
                    add     bx, ax
                    add     bx, ax
                    mov   dh, [es:bx] ;byte1
                    mov   dl, [es:bx+1]; byte2
                    mov   cl, [es:bx+2] ;  byte3
                    mov   ax, si  ;juge if di is times of 2
                    mov   ch, 2
                    div     ch
                    cmp    ah, 0
                    je        Head
            Tail:
                    xor       ax, ax
                    mov      al, cl
                    shl        ax, 4
                    shr        dl, 4
                    add       al, dl
                    jmp       Finish
            Head:
                    xor       ax, ax
                    mov     al, dl
                    and       al, 0fh
                    shl        ax, 8
                    add       al, dh
            Finish:
                    mov     si, ax
                    pop      dx
                    pop      cx
                    pop      bx
                    pop      ax
                    ret



END:    db 0ffh
times 300 db 0
                                





