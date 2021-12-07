/*
    this file define some data struct in protect mode
*/
#ifndef _PROTECT_
#define _PORTECT_

typedef struct s_descriptor{
    u16     limit_low;                  /* Limit */
    u16     base_low;                   /* Base */
    u8       base_mid;                  /* Base */
    u8       attr1;                          /* P(1) DPL(2) DT(1) TYPE(4)*/
    u8       limit_high_attr2;        /* G(1) D(1) O(1) AVL(1) LimitHigh(4)*/
    u8       base_high;                 /* Base */
}DESCRIPTOR;

typedef struct s_gate{
    u16     offset_low;
    u16     selector;
    u8       dcount;                    // just use for call gate , the number of params you want to pass to new stack
    u8       attr;                          // P(1) DPL(2) DT(1) TYPE(4)
    u16     offset_high;
}GATE;


typedef struct s_keyboard_buf{
    int buf[100];
    int head;
    int tail;
    int length;
}KEYBOARD_BUF;


typedef struct s_stack_frame{
    u32     gs;
    u32     fs;
    u32     es;
    u32     ds;
    u32     edi;
    u32     esi;
    u32     ebp;
    u32     kernel_esp;
    u32     ebx;
    u32     edx;
    u32     ecx;
    u32     eax;
    u32     retaddr;
    u32     eip;
    u32     cs;
    u32     eflags;
    u32     esp;
    u32     ss;
}STACK_FRAME;

typedef struct s_proc{
    STACK_FRAME      regs;

    u16     ldt_selector;
    DESCRIPTOR          ldt[LDT_SIZE];
    u32     pid;
    char    p_name[16];
}PROCESS;



#endif