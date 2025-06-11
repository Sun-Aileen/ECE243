.global _start
_start:

li a0, 0xFF200000 #LED location
sw x0, 0(a0) #turn off LEDs
li a1, 0xFF200050 #BUTTON location
li t0, 0 #t0 contains the counter
li a3, 0xFF202000 #TIMER location

li t2, 1000000 #0.01 seconds
li t4, 0 #t4 stores seconds
sw x0, (a3) #clear timer
sw t2, 0x8(a3) #store into low counter
srli t2, t2, 16 # shift t0 right by 16 bits to get the upper 16b
sw t2, 0xc(a3) # store to timer start value register (high)

li t1, 0b0110 #to enable continuous mode and start timer
sw t1, 4(a3) #store in timer control reg

loop:
	addi t0, t0, 1 #increment count by 1
	li t1, 100
	bne t0, t1, reset #reset if t0 reaches 100 milliseconds
	li t0, 0
	addi t4, t4, 128 #increment t4 by 2^7 to reach LED7
	li t1, 1024 #8*128
	bne t4, t1, reset #reset if t4 reaches 8 seconds
	li t4, 0
	reset:
	
	lw a2, 0xC(a1) #read button edgecapture
	beqz a2, run #if no button pressed, keep running
	li t3, 15 #turn off all edge captures
	sw t3, 0xC(a1)
	pause:
		lw a2, 0xC(a1)
		beqz a2, pause #if no button pressed, keep pausing
		li t3, 15 #turn off all edge captures
		sw t3, 0xC(a1)
	run:
	
	timer:
		lw t2, 0(a3) #read timer status register
		andi t2, t2, 0b1 #mask everything except bit 0 (TO bit)
		beqz t2, timer #stop when TO is not 0
		sw x0, 0(a3) #clear TO bit when done
	
	add t5, t4, t0
	sw t5, (a0) #change the LED
	j loop

stop: j stop
