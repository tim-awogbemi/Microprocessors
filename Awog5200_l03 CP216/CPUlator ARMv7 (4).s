/*
-------------------------------------------------------
count2.s
-------------------------------------------------------
Author: Afolabi Awogbemi
ID: 200615200
Email: awog5200@mylaurier.ca
Date: Feb 01, 2025
-------------------------------------------------------
A simple count down program (bge)
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

// Store data in registers
ldr r0, =Counter
mov r3, #5  // Initialize a countdown value
str r3, [r0]

TOP:
ldr r3, [r0]
sub r3, r3, #1 // Decrement the countdown value
cmp r3, #0  // Compare the countdown value to 0
bge TOP   // Branch to top under certain conditions

_stop:
b _stop

.data
COUNTER:
.word 5
.end