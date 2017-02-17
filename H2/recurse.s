.data								# lets compiler know these are variables
linebrk: .asciiz "\n"
Ask_input: .asciiz "Fib number?:\n"	# in unused memory store this string with address Ask_Input
space: .asciiz " "

.text								# lets compiler know this is the code
.align 2							# aligns next value on a word boundary (aligns on 2^2 byte boundary)
.globl main							# initialize main

main: 
	# get fib number
	la $a0, Ask_input				# load address Ask_Input from memory and store it into arguement register 0
	li $v0, 4						# loads the value 4 into register $v0 which is the op code for print string
	syscall 						# reads register $v0 for op code, sees 4 and prints the string located in $a0

	# get and save fib number
	li $v0, 5						# take in input, read integer
	syscall
	move $a0, $v0					# save fib number into $a0

	jal REC 						# jump and link, function call - need this
	j END 							# print and end

# recursion function
REC: 								# return 3*(n-1)+(2*f(n-1))-1;
	subu $sp, $sp, 12				# open frame, save space for $ra, allocate stack
	sw $ra, 0($sp)					# save return address to stack 
	sw $a0, 4($sp)					# save fib number to stack, add 4 to $sp each time we save something new (4 bytes per int)
	sw $s0, 8($sp)					# save $s0 to stack, 8 bytes from $ra, need otherwise test cases above n=1 fails because we're not saving

	bnez $a0, CALC					# BASE CASE: if $a0 != 0, jump to 'CALC'			
	li $v0, 5						# if base case $a0 == 0, then set return value to 5
	j CLEAN							# skip CALC and restore registers

# if n != 0 then recurse
CALC:
	subu $s0, $a0, 1				# $s0 = n - 1, we must save this value in every stack frame
	
	li $s1, 3						# can just use 'mul' also
	mult $s0, $s1					# 3*(n-1)
	mflo $s0						# move result from LO to $s0
	
	subu $a0, $a0, 1				# argument: f(n-1)
	jal REC							# call f(n-1)
				
	li $s2, 2
	mult $v0, $s2					# 2*f(n-1), $v0 = f(n-1)
	mflo $v0						# moves mult result from LO to $s1

	subu $v0, $v0, 1				# (2*f(n-1)) - 1
	addu $v0, $s0, $v0				# $v0 = 3*(n-1)+(2*f(n-1))-1

CLEAN:								# make symmetric to save stack, restore registers from stack
	lw $ra, 0($sp)					# restore return address $ra
	lw $a0, 4($sp)					# restore argument (n)
	lw $s0, 8($sp)					# restore $s0
	addu $sp,$sp, 12				# collapse stack frame, free (pop) stack frame
	jr $ra 							# return to caller, value in $v0

END:
	# print result
	move $a0, $v0 					# copy function result into $a0
	li $v0, 1						# 'print int' command
	syscall
	
	# newline
	la $a0, linebrk					# load linebreak into $a0 
	li $v0, 4						# 'print string' command code
	syscall

	li $v0,10						# 'end program' command code
	syscall

.end main
