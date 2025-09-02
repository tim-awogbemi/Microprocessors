/*
-------------------------------------------------------
l08_t01.s
-------------------------------------------------------
Author:	Afolabi Awogbemi
ID:		200615200
Email:	Awog5200@mylaurier.ca
Date:    2025-03-16
-------------------------------------------------------
Uses a subroutine to write strings to the UART.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

ldr r4, =First
bl  WriteString
ldr r4, =Second
bl  WriteString
ldr r4, =Third
bl  WriteString
ldr r4, =Last
bl  WriteString

_stop:
b    _stop

// Subroutine constants
.equ UART_BASE, 0xff201000  // UART base address

//=======================================================

.equ ENTER, 0x0A           

//=======================================================

WriteString:
/*
-------------------------------------------------------
Writes a null-terminated string to the UART, adds ENTER.
-------------------------------------------------------
Parameters:
  r4 - address of string to print
Uses:
  r0 - holds character to print
  r1 - address of UART
-------------------------------------------------------
*/

//=======================================================

stmfd sp!, {r0, r1, r4}    
ldr   r1, =UART_BASE       

WriteStringLOOP:
ldrb  r0, [r4], #1         
cmp   r0, #0               
beq   WriteStringEND                
str   r0, [r1]             
b     WriteStringLOOP               

WriteStringEND:
mov   r0, #ENTER           
str   r0, [r1]             
ldmfd sp!, {r0, r1, r4}    

bx    lr                   

//=======================================================

bx    lr                 // return from subroutine

.data
.align
// The list of strings
First:
.asciz  "First string"
Second:
.asciz  "Second string"
Third:
.asciz  "Third string"
Last:
.asciz  "Last string"
_Last:    // End of list address

.end