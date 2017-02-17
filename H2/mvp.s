.data
linebrk: .asciiz "\n"
Ask_input1: .asciiz "Player Name:\n"	#in unused memory store this string with address Ask_Input
Ask_input2: .asciiz "Player Number:\n"	
Ask_input3: .asciiz "Player Graduation Year:\n"	
done: .asciiz "DONE\n"
space: .asciiz " "

.text
.align 2
.globl main

main: 
	
READ: 									# read through file
	# get player name
	la $a0, Ask_input1 					# load address Ask_Input from memory and store it into arguement register 0
	li $v0, 4							# loads the value 4 into register $v0 which is the op code for print string
	syscall 							# reads register $v0 for op code, sees 4 and prints the string located in $a0

	# get and save user name
	li $v0, 9 							# malloc, code 9 == allocate heap memory
	li $a0, 32							# $a0 contains the number of bytes you need.
	syscall
	
	move $a0,$v0 						# make a safe copy

	# put string into memory
	li $v0, 8 							# take in input, read string
	syscall
	move $t4,$a0						# save string to t1
	jal CompString						# check if name equal to DONE
	move $t1, $t4
	move $t5, $t1						# we change $t1 when removing trailing \n so need to save $t1 into another variable so we can print with it later
	jal delnewl							# delete newline from end of input
	
	# get user number
	la $a0, Ask_input2 					# load address Ask_Input from memory and store it into arguement register 0
	li $v0, 4							# loads the value 4 into register $v0 which is the op code for print string
	syscall 							# reads register $v0 for op code, sees 4 and prints the string located in $a0

	# save user number
	li $v0, 5							# take in input, read integer
	syscall
	move $t2, $v0

	# get user grad year
	la $a0, Ask_input3 					# load address Ask_Input from memory and store it into arguement register 0
	li $v0, 4							# loads the value 4 into register $v0 which is the op code for print string
	syscall 							# reads register $v0 for op code, sees 4 and prints the string located in $a0

	# save user grad year
	li $v0, 5							# take in input, read integer
	syscall
	move $t3, $v0

	# CREATE LINKED LIST
	li $v0,9            				# malloc, allocate memory
	li $a0,16	  						# 16 bytes
	syscall
	move $s1, $v0						# $s1 = *(first node)
	
	# store player name
	sw $t5, 0($s1)						# at displacement 0
	addi $t5, $t5, 1                    # must increment $t5 to avoid overwriting value in address of $t5

	# store player num
	sw $t2, 4($s1)						# at displacement 4
	addi $t2, $t2, 1

	# store player grad year
	sw $t3, 8($s1)						# at displacement 8
	addi $t3, $t3, 1

	beqz $s8, SAVE 						# if first iteration jump to SAVE
	move $t8, $s8

SORT:	
	# load data for comparison
	lw $s3, 8($s1)						# player 1 grad year
	lw $s4, 8($t7)						# player 2 grad year
	lw $s5, 0($s1)						# player 1 last name
	lw $s6, 0($t7)						# player 2 last name
	lw $t1, 4($s1)						# player 1 number
	lw $t2, 4($t7)						# player 2 number

	# sort
	blt $s3, $s4, SWAP					# if s3 < s4 then swap (sort ascending order grad year)
	bgt $s3, $s4, INC 					# if s3 > s4 then move to next node
	j checkName

MOVE:
	move $t7, $s0                       # reinitialize $t7 to start of list
	move $s8, $s1						# head = current
	sw $s1, 12($s7)						# prev -> next = current
	lw $s7, 12($s7)						# prev = current
	j READ
	
SAVE:
	move $s8, $s1						# head = current
	move $s7, $s1						# prev = current
	move $s0, $s8						# make s0 pointer to head
	move $t7, $s8						# make copy of head
	j READ

SWAP: 									# swap data using bubblesort
	sw $s6, 0($s1)						# need to do 0($s1) not $s5 because you need to move the POINTER not the value in the node
	sw $s5, 0($t7)

	# swap numbers
	sw $t2, 4($s1)
	sw $t1, 4($t7)
	
	# swap years
	sw $s4, 8($s1)						# put year of s2 into s1
	sw $s3, 8($t7)						# put year of s1 into s2

INC:
	lw $t7, 12($t7) 					# increment to next node
	beqz $t7, MOVE 						# if next node is null break to end
	j SORT 								# sort again

checkName: 								# check which name comes first
		move $a1, $s5
		move $a0, $s6
	inn: 
		lb $t1, ($a1)					# load a byte from each string
		lb $t8, ($a0)					# get next char from $a0

		blt $t1, $t8, SWAP				# if current < prev, swap
		bgt $t1, $t8, INC 				# if already in alphabetical order, break

		addi $a1, $a1, 1				# point to next char in name 1
		addi $a0, $a0, 1				# point to next char in name 2
	j inn 								# loop until different

CompString: 							# check if name is "DONE"
	la $t0, done 						# put done string into register

	inner: 
		lb $t1, ($t0)					# load a byte from each string, get next char from $t7, DONE string
		lb $s2, ($a0)					# get next char from $a0, last name string

		bne $t1, $s2, NOT				# if not equal go to not
		beqz $t1, PRINT 				# if reaches end of 'DONE' and doesn't break, move on to sorting

		addi $t0, $t0, 1				# point to next char in DONE
		addi $a0, $a0, 1				# point to next char in name
	j inner

	NOT:
		jr $ra 							# go back to function 

delnewl:								# remove trailing newline
  	la $a3, linebrk
  	lbu $a3, 0($a3)						# gives unsigned byte in a3
	loopStart:	
		beqz $t1, loopEnd				# branch to loopEnd if ($a1) == 0
		lbu $a2, 0($t1)					# $a2 = first byte of $t1
		addi $t1, $t1, 1                # increment $t1 to next letter
		bne $a2, $a3, loopStart			# branch to loopStart if $a2 == $a3
		addi $t1, $t1, -1				# go back 1 index to reach end of line
		sb $0, 0($t1)					# Memory[0 + $t1] = $0, sb: store the least significant byte of a register to a location in memory
	loopEnd:
		jr $ra

PRINT:
	
	move $s1, $s0                       # first loop put head into s1

	#print player name
	li $v0, 4                           # 'print string' command code
	lw $a0, 0($s1)                      # needs value in $a0, now stores name
	syscall

	# print space
	li $v0, 4                           # 'print string' command code
	la $a0, space                       # needs value in $a0, now stores name
	syscall

	# print player number
	lw $a0, 4($s1)                      # player num is 68($s1), copy function result into $a0
	li $v0, 1                           # 'print int' command
	syscall
			
	# newline
	la $a0, linebrk                     # load linebreak into $a0
	li $v0, 4                           # 'print string' command code
	syscall

	lw $s0, 12($s1)                     # make $s0 next node
	beqz $s0, END                       # if $s0 null then end
	j PRINT

END:
	li $v0,10                           # 'end program' command code
	syscall

.end main
