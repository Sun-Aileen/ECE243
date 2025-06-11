.global _start
_start:

li a0, 0xFF200000 #LED location
sw x0, 0(a0) #turn off LEDs
li a1, 0xFF200050 #BUTTON location
li t0, 0 #t0 contains the counter
li a3, 0xFF202000 #TIMER location

li t2, 25000000 #0.25 seconds
sw x0, (a3) #clear timer
sw t2, 0x8(a3) #store into low counter
li t1, 0b0110 #to enable continuous mode and start timer
sw t1, 4(a3) #store in timer control reg

loop:
	addi t0, t0, 1 #increment count by 1
	li t1, 256
	bne t0, t1, reset #reset if t0 reaches 256
	li t0, 0
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
	
	sw t0, (a0) #change the LED
	j loop

stop: j stop