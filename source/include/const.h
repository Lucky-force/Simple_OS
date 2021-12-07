/*          
        this file defines some const symbols
*/
#ifndef _CONST_H
#define _CONST_H

#define SelectorKernelCode 0x10     // the offset in gdt



#define PUBLIC         /* default is public, so we define it as null */
#define PRIVATE static      /* define static as private, make it easy to understand */

/*  the size of GDT , 128 descriptors */
#define GDT_SIZE 128

// the size of IDT , 256 interrupt gate
#define IDT_SIZE 256

// the size of LDT, just need 2 descriptors
#define LDT_SIZE 2

// largest process number
#define MOST_TASKS_NUM 1



/* the port of 8259_A */
#define INT_M_CTL 0x20                          /* interrupt master control*/
#define INT_M_CTLMASK 0x21               /* interrupt master control mask */
#define INT_S_CTL 0xa0                           /* interrupt slave control */
#define INT_S_CTLMASK 0xa1                /* interupt slave control mask */

/* interrupt vector */
#define INT_VECTOR_IRQ0 0x20
#define INT_VECTOR_IRQ8 0x28


//selector attr
#define DA_LDT        0x82         //;This segment is a Local Descriptor Table
#define DA_TaskGate  0x85        //;This segment is a TaskGate
#define DA_386TSS    0x89         //;This segment is a TSS
#define DA_386CGate 0x8c        //;This segment is a CallGate
#define DA_386IGate  0x8e        //; This segment is a IntereputGate
#define DA_386TGate  0x8f        //; This segment is a TrapGate



//privilege
#define KERNEL_PRIVILEGE 0
#define USER_PRIVILEGE      1 


#endif