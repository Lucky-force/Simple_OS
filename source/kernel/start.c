#include "data_type.h"
#include "const.h"
#include "protect.h"
#include "function.h"


PUBLIC    u8    gdt_ptr[6];
PUBLIC    DESCRIPTOR    gdt[GDT_SIZE];
PUBLIC    u8    idt_ptr[6];
PUBLIC    GATE                  idt[IDT_SIZE];
PUBLIC  char* erro_msg[] = {"#DE Divide Error", "#DB RESERVED", "--  NMI Interrupt", "#BP Breakpoint", "#OF Overflow", "#BR BOUND Range Exceeded",
    "#UD Invalid Opcode", "#NM Device Not Available", "#DF Double Fault", "Coprocessor Segment Overrun", "#TS Invalid TSS ", "#NP Segment Not Present",
    "#SS Stack Segment Fault ", "#GP General Protection", "#PF Page Fault", "--  Intel reserved, do not use", "#MF x87 FPU Floating-Point Err", "#AC alignment Check",
    "#MC Machine Check", "#XF  SIMD Floating-Point Exception"};

PUBLIC char* key_borad_char[] = {"",      // 'none' 
"",      // 'Esc'
"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", 
"",      // 'BackSpace'
"    ", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", 
"",     // 'Enter'
"",     // 'Ctrl'
"a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "\'", "`",
"",     // 'L_Shift'
"\\", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/",
"",      // 'R_Shift'
"*", 
"",      //  'Alt'
" ",
"",      // 'CapLock'
"", "", "", "", "", "", "", "", "", "",      // 'F1 ~ F10'
"",      // 'NumLock'
"",      // 'ScrLock'
"",      // 'Home'
"",      // 'CurUp'
"",      // 'PageUp' 
"",      // '-'
};






PUBLIC    u8  PTF[MOST_TASKS_NUM] = {0};       // process taken place flag , descrip which process has exsit  and allocate pid base it., if is 1, this pid process was exsit.
PUBLIC    PROCESS   PCB[MOST_TASKS_NUM];
PUBLIC    u32 GDT_END = 0x30;      //  descrip the end of GDT, base on it we can add new descriptor to GDT




PUBLIC void IniGdt(){

    memcpy(gdt, (void*)*((u32*)(&gdt_ptr[2])), *((u16*)(gdt_ptr)) + 1);

    u16* gdt_limit = (u16*)(&gdt_ptr[0]);
    u32* gdt_base = (u32*)(&gdt_ptr[2]);

    *(gdt_limit) = sizeof(DESCRIPTOR)*GDT_SIZE-1;
    *(gdt_base) = (u32)gdt;


}

PUBLIC void IniIdt(){
    u16* idt_limit = (u16*)(&idt_ptr[0]);
    u32* idt_base = (u32*)(&idt_ptr[2]);

    *(idt_limit) = IDT_SIZE*sizeof(GATE)-1;
    *(idt_base) = (u32*)idt;

}

PUBLIC void Print(char* s, int color){
    int i = 0;
    char* str = s;
    for(; *s != 0; s++){
        i++;
    }
    if(i != 0){
        print(str, i, color);
    }
}

PUBLIC void PrintInt(u32 n, int color){
    char num[9] = {0};
    u32 m = n;
    u32 k;
    for(int i=7; i >= 0;i-- ){
        k = m%16;
        m = m/16;
        switch (k)
        {
        case 0: num[i] = '0';
            break;
        case 1: num[i] = '1';
            break;
        case 2: num[i] = '2';
            break;
        case 3: num[i] = '3';
            break;
        case 4: num[i] = '4';
            break;
        case 5: num[i] = '5';
            break;
        case 6: num[i] = '6';
            break;
        case 7: num[i] = '7';
            break;
        case 8: num[i] = '8';
            break;
        case 9: num[i] = '9';
            break;
        case 10: num[i] = 'A';
            break;
        case 11: num[i] = 'B';
            break;
        case 12: num[i] = 'C';
            break;
        case 13: num[i] = 'D';
            break;
        case 14: num[i] = 'E';
            break;
        case 15: num[i] = 'F';
            break;
        }
    }     
    Print(num, color);

}

PUBLIC void Ini_8259A(){
    // ICW1
    out_byte(INT_M_CTL, 0x11);    // set master
    out_byte(INT_S_CTL, 0x11);     // set slave
    //ICW2                                          
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);                      // set the master interrupt entry
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);                       //set the slave interrupt entry
    //ICW3
    out_byte(INT_M_CTLMASK, 0x4);
    out_byte(INT_S_CTLMASK, 0x2);
    //ICW4
    out_byte(INT_M_CTLMASK, 0x1);
    out_byte(INT_S_CTLMASK, 0x1);
    //OCW1
    out_byte(INT_M_CTLMASK, 0xfd);
    out_byte(INT_S_CTLMASK, 0xff);          // ignore all interrupt tmp
}

PUBLIC void PrintAL(){
    dispal();
}

PUBLIC void PrintReturn(){
    printReturn();
}

PUBLIC void Clean(){
    clean();
}


PUBLIC void Init_idt_desc(u8 vector, u8 desc_type, void* handler, u8 privilege){
    GATE* gate_ptr = &idt[vector];
    u32 base = (u32)handler;
    gate_ptr->offset_low = base & 0xffff;
    gate_ptr->selector = SelectorKernelCode;
    gate_ptr->dcount = 0;     //not task gate, just 0
    gate_ptr->attr = desc_type | (privilege << 5);
    gate_ptr->offset_high = (base >>16) & 0xffff;
}

PUBLIC void Init_idt(){
    Ini_8259A();

    Init_idt_desc(0, DA_386IGate, divide_error, KERNEL_PRIVILEGE);
    Init_idt_desc(1, DA_386IGate, single_step_exception, KERNEL_PRIVILEGE);
    Init_idt_desc(2, DA_386IGate, nmi, KERNEL_PRIVILEGE);
    Init_idt_desc(3, DA_386IGate, breakpoint_exception, KERNEL_PRIVILEGE);
    Init_idt_desc(4, DA_386IGate, overflow, KERNEL_PRIVILEGE);
    Init_idt_desc(5, DA_386IGate, bounds_check, KERNEL_PRIVILEGE);
    Init_idt_desc(6, DA_386IGate, inval_opcode, KERNEL_PRIVILEGE);
    Init_idt_desc(7, DA_386IGate, copr_not_available, KERNEL_PRIVILEGE);
    Init_idt_desc(8, DA_386IGate, double_fault, KERNEL_PRIVILEGE);
    Init_idt_desc(9, DA_386IGate, copr_seg_overrun, KERNEL_PRIVILEGE);
    Init_idt_desc(10, DA_386IGate, inval_tss, KERNEL_PRIVILEGE);
    Init_idt_desc(11, DA_386IGate, segment_not_present, KERNEL_PRIVILEGE);
    Init_idt_desc(12, DA_386IGate, stack_exception, KERNEL_PRIVILEGE);
    Init_idt_desc(13, DA_386IGate, general_protection, KERNEL_PRIVILEGE);
    Init_idt_desc(14, DA_386IGate, page_fault, KERNEL_PRIVILEGE);
    Init_idt_desc(16, DA_386IGate, copr_error, KERNEL_PRIVILEGE);
    

    Init_idt_desc(INT_VECTOR_IRQ0 + 0, DA_386IGate, hwint0, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGate, hwint1, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 2, DA_386IGate, hwint2, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 3, DA_386IGate, hwint3, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 4, DA_386IGate, hwint4, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 5, DA_386IGate, hwint5, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 6, DA_386IGate, hwint6, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ0 + 7, DA_386IGate, hwint7, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 0, DA_386IGate, hwint8, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 1, DA_386IGate, hwint9, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 2, DA_386IGate, hwint10, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 3, DA_386IGate, hwint11, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 4, DA_386IGate, hwint12, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 5, DA_386IGate, hwint13, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 6, DA_386IGate, hwint14, KERNEL_PRIVILEGE);
    Init_idt_desc(INT_VECTOR_IRQ8 + 7, DA_386IGate, hwint15, KERNEL_PRIVILEGE);

}


PUBLIC void exception_handler(int vec_number, u32 err_code, u32 eip, u32 cs, u32 eflags){
    int text_color = 0x74; // grey background, red char

    //make a too large tmp vary is easy to cause fault, maybe because stack is too small, so, set the string as public vary

    Clean();
    Print("Exception >_<", text_color);
    PrintReturn();
    Print(erro_msg[vec_number], text_color);
    PrintReturn();
    Print("EFLAGS : ", text_color);
    PrintInt(eflags, text_color);
    PrintReturn();
    Print("CS : ", text_color);
    PrintInt(cs, text_color);
    PrintReturn();
    Print("EIP : ", text_color);
    PrintInt(eip, text_color);
    PrintReturn();

    if(err_code != 0xffffffff){
        Print("ERORR CODE : ", text_color);
        PrintInt(err_code, text_color);
    }
}

//===================
// this is test function
PUBLIC void testprint(){
    Print("testtesttest!!!!", 0x74);

}
//====================


PUBLIC void HWInt(int number){
    switch (number)
    {
    case 0:     ClockInt()          ;    break;
    case 1:     KeyboardInt()    ;    break;
    case 2:         ; break;
    default:
        break;
    }

    if(number > 7){
        finish_int_s();
    }else{
        finish_int_m();
    }
}


PUBLIC void ClockInt(){
    Print("x", 0xc);
}


KEYBOARD_BUF Buf;
KEYBOARD_BUF* Buf_ptr = &Buf;

PUBLIC void Keyboard_Init(){
    Buf_ptr->head = 0;
    Buf_ptr->tail = 0;
    Buf_ptr->length = 0;
}

PUBLIC void Add_to_Buf(int scan_code){
    if(Buf_ptr->tail == Buf_ptr->head)
    goto end;
    Buf_ptr->buf[Buf_ptr->tail] = scan_code;
    Buf_ptr->tail = (Buf_ptr->tail + 1)%100;
    end:
}

PUBLIC int Remv_from_Buf(){
    if(Buf_ptr->tail == Buf_ptr->head)
    return -1;
    int scan_code = Buf_ptr->buf[Buf_ptr->head];
    Buf_ptr->head = (Buf_ptr->head +1)%100;
    return scan_code;
}


PUBLIC void KeyboardInt(){
    int scan_code = in_byte(0x60);
    
    if(scan_code == 0xe && !is_top()){
        BackSpace();
        goto end;
    }else if(scan_code == 0x1c){
        PrintReturn();
        goto end;
    }
    

    end:
}

PUBLIC BackSpace(){
    back_space();
}




PUBLIC void ProcessManage(){



}