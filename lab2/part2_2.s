.global _start
_start:

# s3 should contain the grade of the person with the student number, -1 if not found
# s0 has the student number being searched

    li s0, 681936

	
# Your code goes below this line and above iloop

	la s1, Snumbers
	la s2, Grades
	lw s3, (s1)
	
loop:
	beq s3, s0, load
	beq s3, zero, notFound
	
	addi s1, s1, 4
	addi s2, s2, 1
	lw s3, (s1)
	
	j loop
	
load:
	la s1, result
	lb s3, (s2)
	
	j memLoad

notFound:
	li s3, -1

memLoad:
	la s1, result
	sb s3, (s1)

iloop: j iloop

/* result should hold the grade of the student number put into s0, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
