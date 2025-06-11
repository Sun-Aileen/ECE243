/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start
_start:

/* Your code here  */
	la t4, TEST_NUM
	lw a0, 0(t4) #store first number of TEST_NUM in a0
	li t1, 0 #store largest_ones in t1
	li t3, 0 #store largest_zeroes in t3
	li a1, 0 #give a1 starting value of 0
	testloop:
		call ONES #call function to count 1s
		bge t1, t5, skipone #if t1 >= t5, don't move t5 value into t1
		mv t1, t5
		skipone:
		call ONES #call function to count 0s
		bge t3, t5, skipzero #if t3 >= t5, don't move t5 value into t1
		mv t3, t5
		skipzero:
		addi t4, t4, 4 #move to next TEST_NUM unless we reached a0 = 0
		lw a0, 0(t4)
		beqz a0, endtest
		j testloop
	endtest:
	la t0, LargestOnes #store t1, t3
	sw t1, (t0)
	la t0, LargestZeroes
	sw t3, (t0)
	
	.equ LEDs, 0xFF200000 #put values on LEDs
	la s2, LEDs
	and t1, t1, 0x3FF
	and t3, t3, 0x3FF
	lights:
		sw t1, (s2) #puts LargestOnes on LED
		call delay
		sw t3, (s2) #puts LargestZeroes on LED
		call delay
		j lights #loop

stop: j stop #should never reach this

#uses t0, t2, t6, s0, a1, t5
ONES:
	li s0, 32 #iterate loop 32 times
	li t0, 0 #t0 stores number of 1s / 0s
	mv t6, a0 #store the number in t6

	loop:
	addi s0, s0, -1 #decrease s0 by 1
	and t2, t6, 1 #get rightmost bit in t2
	beq t2, a1, one
	addi t0, t0, 1 #add 1 to t0 if t2 does not equal a1
	one:
	srl t6, t6, 1 #shift bits right by 1
	beqz s0, end #end loop when s0 is 0
	j loop
	
	end:
	xor a1, a1, 1 #every call of the loop, flip a1 between 0 and 1
	mv t5, t0 #t5 stores number of 1s / 0s
	ret

#reuses t2
delay:
	li t2, 100000000
	delayloop:
		addi t2, t2, -1
		bnez t2, delayloop
	ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0
