
SelectorKernelCode          EQU             16              ; change it base on the flat_code offset in your gdt

;externed functions

extern      IniGdt
extern      Print
extern      PrintAL
extern      Clean
extern      PrintReturn
extern      IniIdt
extern      Init_idt
extern      exception_handler
extern      testprint
extern      HWInt
extern      Keyboard_Init

;extern end

;global interrupt functions

global divide_error
global single_step_exception
global nmi
global breakpoint_exception
global overflow
global bounds_check
global inval_opcode
global copr_not_available
global double_fault
global copr_seg_overrun
global inval_tss
global segment_not_present
global stack_exception
global general_protection
global page_fault
global copr_error


global hwint0
global hwint1
global hwint2
global hwint3
global hwint4
global hwint5
global hwint6
global hwint7
global hwint8
global hwint9
global hwint10
global hwint11
global hwint12
global hwint13
global hwint14
global hwint15


;global end


;externed variables

extern      gdt_ptr
extern      idt_ptr

;extern end

[SECTION .bss]
StackSpace              resb            5*1024  ; initial a stack, size is 5K
StackTop:                                                ; use as a offset, the top of stack





[SECTION .data]
VideoPointer:            dd              0          ; point to screen


[SECTION .text]

global      _start
global      VideoPointer

_start:
            mov     esp, StackTop         ; we don't need to write org ......  , ld and nasm will do it, we just use the symbol
            mov     ebp, esp
            
            sgdt     [gdt_ptr]                 ; copy the base and size information of gdt to gdt_ptr
            call      IniGdt
            lgdt      [gdt_ptr]

            jmp     SelectorKernelCode:init

init:
            call      Clean
            call      IniIdt
            call      Init_idt
            lidt       [idt_ptr]
            ;init keyboard buffer
            call       Keyboard_Init
            ;open interrupt
            sti
            call testprint
            jmp      $
            hlt                ; stop






divide_error:
                push    0xffffffff
                push    0
                jmp     exception
single_step_exception:
                push    0xffffffff
                push    1
                jmp      exception
nmi:
                push    0xffffffff
                push    2
                jmp      exception
breakpoint_exception:
                push    0xffffffff
                push    3
                jmp      exception
overflow:
                push    0xffffffff
                push    4
                jmp      exception
bounds_check:
                push    0xffffffff
                push    5
                jmp      exception
inval_opcode:

                push    0xffffffff
                push    6
                jmp      exception
copr_not_available:
                push    0xffffffff
                push    7
                jmp      exception
double_fault:
                push    8
                jmp      exception
copr_seg_overrun:
                push    0xffffffff
                push    9
                jmp      exception
inval_tss:
                push    10
                jmp     exception
segment_not_present:
                push    11
                jmp      exception
stack_exception:
                push    12
                jmp     exception
general_protection:
                push    13
                jmp      exception
page_fault:
                push    14
                jmp     exception
copr_error:
                push    0xffffffff
                push    16
                jmp      exception

exception:
                call      exception_handler
                add       esp, 8
                hlt


hwint0:
                push    0
                jmp     hwint_handler
hwint1:
                push    1
                jmp     hwint_handler
hwint2:
                push    2
                jmp     hwint_handler
hwint3:
                push    3
                jmp     hwint_handler
hwint4:
                push    4
                jmp     hwint_handler
hwint5:
                push    5
                jmp     hwint_handler
hwint6:
                push    6
                jmp     hwint_handler
hwint7:
                push    7
                jmp     hwint_handler
hwint8:
                push    8
                jmp     hwint_handler
hwint9:
                push    9
                jmp     hwint_handler
hwint10:
                push    10
                jmp     hwint_handler
hwint11:
                push    11
                jmp     hwint_handler
hwint12:
                push    12
                jmp     hwint_handler
hwint13:
                push    13
                jmp     hwint_handler
hwint14:
                push    14
                jmp     hwint_handler
hwint15:
                push    15
                jmp     hwint_handler
hwint_handler:
                call    HWInt
                add     esp, 4
                sti
                iretd