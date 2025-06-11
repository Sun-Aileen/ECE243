/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	
	/* Put your code here */
	la t0, InputWord
	lw t1, 0(t0) #store the inputword in t1
	li s0, 32 #iterate loop 32 times
	li t0, 0 #t0 stores number of 1s

	loop:
	addi s0, s0, -1 #decrease s0 by 1
	and t2, t1, 1 #get rightmost bit in t2
	beqz t2, one
	addi t0, t0, 1 #add 1 to t0 if t2 does not equal 0
	one:
	srl t1, t1, 1 #shift bits right by 1
	beqz s0, end #end loop when s0 is 0
	j loop
	
	end:
	la s1, Answer
	sw t0, (s1)

    stop: j stop

.data
InputWord: .word 0x4a01fead

Answer: .word 0
