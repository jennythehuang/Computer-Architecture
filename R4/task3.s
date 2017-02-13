# Program to print out the integers from 0 to 10
.data
linebrk: .asciiz "\n"

.text
.align 2	
.globl main

main:
	li $s0, 11 			# literal assignment
	li $t0, 0 			# literal assignment

loop: 
	beq $t0, $s0, done 	# if $t0==$s1 then end loop
	li $v0, 1			# 'print integer' command code, $v0 stores result
	move $a0, $t0		# needs value in $a0, $a0 stores argument
	syscall
	
	# newline
    li $v0, 4			# 'print string' command code
    la $a0, linebrk		# needs value in $a0, now stores linebreak
    syscall				# newline
	
	addi $t0, $t0, 1	# increment index to continue loop: ++i
	j loop 				# restart loop

done:
	li $v0,10 			# 'terminate' command code
	syscall				# exit

.end main