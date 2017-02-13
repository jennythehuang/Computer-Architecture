# read users name and age from terminal
# prints out year that person will turn 50 years old
# ie, "Dan will turn 50 years old in 2024"

.data

Ask_input1: .asciiz "What is your name?\n"	#in unused memory store this string with address Ask_Input
Ask_input2: .asciiz "What is your age?\n" 	
result: .asciiz " will turn 50 years old in "
period: .asciiz "."
buffer: .space 128 			# space to copy input into, 25 spaces for inputted string
linebrk: .asciiz "\n"
over50: .asciiz "Woah! Already celebrated the 50th!"


.text

.align 2
.globl main


main: 


	getData:

		#get user name
		la $a0, Ask_input1 				# load address Ask_Input from memory and store it into arguement register 0
		li $v0, 4						# loads the value 4 into register $v0 which is the op code for print string
		syscall 						# reads register $v0 for op code, sees 4 and prints the string located in $a0

		# get and save user name
		li $v0, 9 						# code 9 == allocate heap memory
		li $a0, 128						# $a0 contains the number of bytes you need.
		syscall
		move $a0,$v0 					# make a safe copy

		# put string into memory
		li $v0, 8 						# take in input, read string
		syscall
		move $t1,$a0					# save string to t1
		move $t5, $t1					# we change $t1 when removing trailing \n so need to save $t1 into another variable so we can print with it later
		
		# remove trailing newline
  		la $a3, linebrk
  		lbu $a3, 0($a3)					# gives unsigned byte in a3
		loopStart:
			  beqz $t1, loopEnd			# branch to loopEnd if ($a1) == 0
			  lbu $a2, 0($t1)			# $a2 = Memory[$t1 + $a1]
			  addi $t1, $t1, 1
			  bne $a2, $a3, loopStart	# branch to loopStart if $a2 == $a3
			  addi $t1, $t1, -1			# go back 1 index to reach end of line
			  sb $0, 0($t1)				# Memory[0 + $t1] = $0, sb: store the least significant byte of a register to a location in memory
		loopEnd: 

		#get user age
		la $a0, Ask_input2 				# load address Ask_Input from memory and store it into arguement register 0
		li $v0, 4						# loads the value 4 into register $v0 which is the op code for print string
		syscall 						# reads register $v0 for op code, sees 4 and prints the string located in $a0

		#get and save user age
		li $v0, 5						# take in input, read integer
		syscall
		move $t2, $v0
	

	math: #do the math to find out year

		li $s2, 50						# literal assignment

		
		CheckOver50: # if user > 50 years old
		
			slt $t3, $t2, $s2			# Set on less than, $t3 = 1 if $t1 < $t2, otherwise $t3 = 0; need for > or < comparison
			bne $t3, $0, false			# if $t3 = 1, jump to 'false'
			li $v0, 4					# 'print string' command code
			la $a0, over50				# print exit string
			syscall
			
			# newline
			li $v0, 4			
			la $a0, linebrk		
			syscall

			j end						# jump to end
		
		
		false: #user not 50 yet
		
			sub $s1, $s2, $t2			# $s1 = $s2 - $t2, $t2 is age
			move $a0, $t2
			li $s3, 2017
			add $s2, $s3, $s1			# $s1 = $s3 + $s1, $s2 is year user will turn 50

	
	print:

		#print name
		li $v0, 4						# 'print string' command code
		move $a0, $t5					# needs value in $a0, now stores name
		syscall
		
		#print result string
		li $v0, 4
		la $a0, result
		syscall
		
		#print year
		li $v0, 1
		move $a0, $s2
		syscall
		
		#print period at end of sentence
		li $v0, 4
		la $a0, period
		syscall

		# newline
		li $v0, 4			
		la $a0, linebrk		
		syscall


	#end program
	end: 
		li $v0,10
		syscall


.end main
