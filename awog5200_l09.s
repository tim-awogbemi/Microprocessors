/*
-------------------------------------------------------
l09.s
-------------------------------------------------------
Author:		Afolabi Awogbemi
ID:			200615200
Email:		awog5200@mylaurier.ca
Date:    	2025-04-05
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
.section .vectors, "ax"
B _start            // reset vector
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0             // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.equ  UART_ADDR,  0xff201000
.equ  TIMER_BASE, 0xff202000
.equ  ENTER, 0xA

.org 0x1000   // Start at memory location 1000
.text
.global _start
_start:
/* Set up stack pointers for IRQ and SVC processor modes */
MOV R1, #0b11010010 // interrupts masked, MODE = IRQ
MSR CPSR_c, R1 // change to IRQ mode
LDR SP, =0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
MOV R1, #0b11010011 // interrupts masked, MODE = SVC
MSR CPSR, R1 // change to supervisor mode
LDR SP, =0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
BL CONFIG_GIC // configure the ARM GIC
// set timer
BL TIMER_SETTING
// enable IRQ interrupts in the processor
MOV R0, #0b01010011 // IRQ unmasked, MODE = SVC
MSR CPSR_c, R0
IDLE:
B IDLE // main program simply idles

/* Define the exception service routines */
/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
B SERVICE_UND
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
stmfd sp!,{R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
LDR R4, =0xFFFEC100
LDR R5, [R4, #0x0C] // read from ICCIAR

CMP R5, #72
BLEQ INTER_TIMER_ISR

EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
STR R5, [R4, #0x10] // write to ICCEOIR
//BL STOP_TIMER

ldmfd sp!, {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
B SERVICE_FIQ
//.end

/*
* Configure the Generic Interrupt Controller (GIC)
*/
.global CONFIG_GIC
CONFIG_GIC:
stmfd sp!, {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
MOV R0, #72 // Interval timer (Interrupt ID = 72)
MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT
/* configure the GIC CPU Interface */
LDR R0, =0xFFFEC100 // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
LDR R1, =0xFFFF // enable interrupts of all priorities levels
STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
MOV R1, #1
STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
LDR R0, =0xFFFED000
STR R1, [R0]
ldmfd sp!, {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
stmfd sp!, {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
LSR R4, R0, #3 // calculate reg_offset
BIC R4, R4, #3 // R4 = reg_offset
LDR R2, =0xFFFED100
ADD R4, R2, R4 // R4 = address of ICDISER
AND R2, R0, #0x1F // N mod 32
MOV R5, #1 // enable
LSL R2, R5, R2 // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
LDR R3, [R4] // read current register value
ORR R3, R3, R2 // set the enable bit
STR R3, [R4] // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
BIC R4, R0, #3 // R4 = reg_offset
LDR R2, =0xFFFED800
ADD R4, R2, R4 // R4 = word address of ICDIPTR
AND R2, R0, #0x3 // N mod 4
ADD R4, R2, R4 // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
STRB R1, [R4]
ldmfd sp!, {R4-R5, PC}

/*************************************************************************
* Timer setting
*
************************************************************************/
.global TIMER_SETTING
TIMER_SETTING:

stmfd sp!, {R0-R3, LR}    
    

ldr R0, =TIMER_BASE
    

mov R1, #0
str R1, [R0]
    

ldr R1, =100000000
    

str R1, [R0, #8]
    

lsr R2, R1, #16       
str R2, [R0, #12]
    

mov R3, #0b111        
str R3, [R0, #4]      
    
ldmfd sp!, {R0-R3, PC}    


/*************************************************************************
* Interrupt service routine
*
************************************************************************/
.global INTER_TIMER_ISR
INTER_TIMER_ISR:

stmfd sp!, {R4-R6, LR}  
    

ldr R4, =UART_ADDR        
ldr R5, =ARR1             
    
WRITE_LOOP:
ldrb R6, [R5], #1         
cmp R6, #0                
BEQ WRITE_DONE            
    
str R6, [R4]              
B WRITE_LOOP              
    
WRITE_DONE:
    
mov R6, #ENTER            
str R6, [R4]              
    
    
ldr R4, =TIMER_BASE       
mov R5, #0                
str R5, [R4]              
    
ldmfd sp!, {R4-R6, PC}



/*****************************************
* data section
*
******************************************/
.data
.align
ARR1:
.asciz "Timeout"

.end

	