.global _start
_start:

li a0, 0xFF200000 #LED location
sw x0, 0(a0) #turn off LEDs
li a1, 0xFF200050 #BUTTON location
li a3, 0

button_press:
	lw a2, (a1) #read button data
	
	andi t0, a2, 1 #take in last bit of data (0001)
	li t1, 1
	bne t0, t1, skip_0 #if pressed, call pressed_0
	call pressed_0
	skip_0:
	
	andi t0, a2, 2 #take in 0010
	li t1, 2
	bne t0, t1, skip_1
	call pressed_1
	skip_1:
	
	andi t0, a2, 4 #take in 0100
	li t1, 4
	bne t0, t1, skip_2
	call pressed_2
	skip_2:
	
	andi t0, a2, 8 #take in 1000
	li t1, 8
	bne t0, t1, skip_3
	call pressed_3
	
	skip_3:
	j button_press

pressed_0:
	li t1, 1
	wait_0:
		lw a2, (a1) #load button data
		andi t0, a2, 1 #take data bit
		bne t0, t1, run_0 #run once button is released
		j wait_0
	
	run_0:
	li a3, 1
	sw a3, 0(a0) #change LED to display 1
	ret

pressed_1:
	li t1, 2
	wait_1:
		lw a2, (a1) #load button data
		andi t0, a2, 2 #take data bit
		bne t0, t1, run_1 #run once button is released
		j wait_1
	
	run_1:
	li t2, 0xE
	beq a3, t2, max #don't increment if reached 15
	addi a3, a3, 1 #increment display number by 1
	max:
	sw a3, 0(a0)
	ret

pressed_2:
	li t1, 4
	wait_2:
		lw a2, (a1) #load button data
		andi t0, a2, 4 #take data bit
		bne t0, t1, run_2 #run once button is released
		j wait_2
	
	run_2:
	beq a3, t1, min #don't decrement if reached 1
	addi a3, a3, -1
	min:
	sw a3, 0(a0)
	ret

pressed_3:
	li t1, 8
	wait_3:
		lw a2, (a1) #load button data
		andi t0, a2, 8 #take data bit
		bne t0, t1, run_3 #run once button is released
		j wait_3
	
	run_3:
	sw x0, 0(a0) #turn off LEDs
	li a3, 1 #reset a3 to 1
	
	pressed_again:
		lw a2, (a1) #load button data
		andi t0, a2, 15 #take all four data bits (1111)
		beqz t0, pressed_again #register if any button is pressed
			released_again:
			lw a2, (a1)
			andi t0, a2, 15
			bnez t0, released_again #register if all buttons are let go
	
	sw a3, 0(a0)
	ret

stop: j stop