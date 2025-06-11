.global _start
_start:

li a0, 0xFF200000 #LED location
sw x0, 0(a0) #turn off LEDs
li a1, 0xFF200050 #BUTTON location
li t0, 0 #t0 contains the counter

loop:
	addi t0, t0, 1 #increment count by 1
	li t1, 256
	bne t0, t1, reset #reset if t0 reaches 256
	li t0, 0
	reset:
	
	li t2, 50000000 #delay (hopefully 0.25 sec)
	do_delay:
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
		addi t2, t2, -1
		bnez t2, do_delay
	
	sw t0, (a0) #change the LED
	j loop

stop: j stop
