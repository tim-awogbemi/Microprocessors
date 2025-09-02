/*
-------------------------------------------------------
list_demo.s
-------------------------------------------------------
Author:  Afolabi Awogbemi
ID:      200615200
Email:   awog5200@mylaurier.ca
Date:    2025-02-10
-------------------------------------------------------
A simple list demo program. Traverses all elements of an integer list.
r0: temp storage of value in list
r2: address of start of list
r3: address of end of list
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

ldr    r2, =Data    // Store address of start of list
ldr    r3, =_Data   // Store address of end of list
ldr    r6, [r2]
ldr    r7, [r2], #4

Loop:
ldr    r0, [r2], #4 // Read address with post-increment (r0 = *r2, r2 += 4)
cmp    r0, r6
movgt  r0, r6
cmp    r0, r7
movlt  r0, r7
cmp    r3, r2       // Compare current address with end of list
bne    Loop         // If not at end, continue

_stop:
b _stop

.data
.align
Data:
.word   4,5,-9,0,3,0,8,-7,12    // The list of data
_Data: // End of list address

.end	
	