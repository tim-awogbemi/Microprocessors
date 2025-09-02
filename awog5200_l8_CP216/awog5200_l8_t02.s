/*
-------------------------------------------------------
l08_t02.s
-------------------------------------------------------
Author:	Afolabi Awogbemi
ID:		200615200
Email:	Awog5200@mylaurier.ca
Date:    2025-03-16
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
// Constants
.equ SIZE, 20 // Size of string buffer storage (bytes)

.org 0x1000   // Start at memory location 1000
.text         // Code section
.global _start
_start:

//=======================================================

mov    r5, #SIZE        

//=======================================================

ldr    r4, =First
bl    ReadString
ldr    r4, =Second
bl    ReadString
ldr    r4, =Third
bl     ReadString
ldr    r4, =Last
bl     ReadString

_stop:
b _stop

// Subroutine constants
.equ UART_BASE, 0xff201000  // UART base address
.equ ENTER, 0x0A            // The enter key code
.equ VALID, 0x8000          // Valid data in UART mask

ReadString:
/*
-------------------------------------------------------
Reads an ENTER terminated string from the UART.
-------------------------------------------------------
Parameters:
  r4 - address of string buffer
  r5 - size of string buffer
Uses:
  r0 - holds character to print
  r1 - address of UART
-------------------------------------------------------
*/

//=======================================================

stmfd  sp!, {r0-r2, r4}     
ldr    r1, =UART_BASE       
mov    r2, #0               

ReadStringLOOP:
ldr    r0, [r1]             
tst    r0, #VALID           
beq    _ReadString          
and    r0, r0, #0xFF        
cmp    r0, #ENTER           
beq    _ReadString          
cmp    r2, r5               
beq    _ReadString          
strb   r0, [r4]             
add    r4, r4, #1           
add    r2, r2, #1           
b      ReadStringLOOP               

_ReadString:
mov    r0, #0               
strb   r0, [r4]             
ldmfd  sp!, {r0-r2, r4}     
bx     lr                   

//=======================================================

bx    lr                    

.data
.align
// The list of strings
First:
.space  SIZE
Second:
.space SIZE
Third:
.space SIZE
Last:
.space SIZE
_Last:    // End of list address

.end	
	