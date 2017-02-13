.data
linebrk: .asciiz "\n"
Ask_input: .asciiz "What is your fib number?:\n"	#in unused memory store this string with address Ask_Input

.text

.align 2
.globl main


main: 

	# get fib number
	la $a0, Ask_input				# load address Ask_Input from memory and store it into arguement register 0
	li $v0, 4						# loads the value 4 into register $v0 which is the op code for print string
	syscall 						# reads register $v0 for op code, sees 4 and prints the string located in $a0

	# get and fib number
	li $v0, 5						# take in input, read integer
	syscall
	move $t4, $v0					# save fib number into $t4
	
	# base case
	li $s1, 2						# fib1 = 2
	li $s2, 2						# fib2 = 2
					
									#printf("%d", fib1);
	# print f(1)
		li $v0, 1
		move $a0, $s1				# move COPIES, doensn't move
		syscall
	# newline
		li $v0, 4			
		la $a0, linebrk		
		syscall

	li $t6, 1						# for base, if n == 1
	beq $t4, $t6, END
	# beq $t7, $0, END				# if $t7 =0, go to END	
					 				
					 				# printf("\n%d", fib2);
	# print f(2)	
		li $v0, 1
		move $a0, $s2
		syscall

	# iteration
	li $t1, 2 						# int count = 2;
	LOOP:
		
		# while(count < n){
		slt $t3, $t1, $t4			# Set on less than, $t3 = 1 if $t1 < $t4, otherwise $t3 = 0; need for > or < comparison
		beqz $t3, END				# if $t3 == 0, goes to END
		add $a3, $s1, $s2 			# fib3 = fib2+fib1;
		
		# printf("\n%d", fib3);
		# newline
		li $v0, 4			
		la $a0, linebrk		
		syscall
		#print f(3)
		li $v0, 1
		move $a0, $a3
		syscall

		# fib1 = fib2, fib2 = fib3
		move $s1, $s2
		move $s2, $a0
		
		# count++
		addi $t1, $t1, 1
		j LOOP


	# end program
	END: 
		# newline
		li $v0, 4			
		la $a0, linebrk		
		syscall
		
		li $v0,10
		syscall

.end main

