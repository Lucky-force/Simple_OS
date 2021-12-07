/* define some functions written is asm */


#ifndef _FUNCTION_
#define _FUCTION_

PUBLIC void memcpy(void* pDst, void* pSrc, int Size);

PUBLIC void print(char* Pointer, int num, int color);

PUBLIC void out_byte(u16 port, u8 byte);

PUBLIC int in_byte(u16 port);

PUBLIC int is_top();

PUBLIC void dispal();

PUBLIC void clean();

PUBLIC void printReturn();

PUBLIC void back_space();

// interrupt functions ===================

PUBLIC void divide_error();
PUBLIC void single_step_exception();
PUBLIC void nmi();
PUBLIC void breakpoint_exception();
PUBLIC void overflow();
PUBLIC void bounds_check();
PUBLIC void inval_opcode();
PUBLIC void copr_not_available();
PUBLIC void double_fault();
PUBLIC void copr_seg_overrun();
PUBLIC void inval_tss();
PUBLIC void segment_not_present();
PUBLIC void stack_exception();
PUBLIC void general_protection();
PUBLIC void page_fault();
PUBLIC void copr_error();


PUBLIC void hwint0();
PUBLIC void hwint1();
PUBLIC void hwint2();
PUBLIC void hwint3();
PUBLIC void hwint4();
PUBLIC void hwint5();
PUBLIC void hwint6();
PUBLIC void hwint7();
PUBLIC void hwint8();
PUBLIC void hwint9();
PUBLIC void hwint10();
PUBLIC void hwint11();
PUBLIC void hwint12();
PUBLIC void hwint13();
PUBLIC void hwint14();
PUBLIC void hwint15();

PUBLIC void finish_int_m();
PUBLIC void finish_int_s();
// ==================================

#endif