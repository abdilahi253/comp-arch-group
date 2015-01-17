.data
matrix_one:	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
matrix_two: 	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
matrix_product:	.word 0 : 256 #1D Matrix to hold the product of the two matrices

offset:		.word 0
prompt:		.asciiz "What seed would you like to give the matrix?:"
base:		.asciiz "Base Address: "
sum_address:	.asciiz "Generated Address: "
m_label_one:	.asciiz "Matrix One"
m_label_two:	.asciiz "Matrix Two"
space:		.asciiz " "
new_line: 	.asciiz "\n"

debug_one:	.asciiz "In Load 1st Matrix::DEBUG"
debug_two:	.asciiz "In Load 2nd Matrix::DEBUG"
debug_offset:	.asciiz "Debugging the offset of the register: "
debug_counter:	.asciiz "Counter is at: "
debug_mod:	.asciiz "Remainder is "

# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base
# If we wanted to access the higher language equivalent of [3][4], with 16 columns and a data type of a 
# .word (4 bytes) we would calculate offset_from_base with --> 4 * (16 * 3 + 4) = 64. 64 is the amount
# by which you need to offset from base address in order to accurately store saved data of the matrix 
# multiplication.  

.text		
main:

	la $s1, matrix_one #Grab starting address of matrix one
	la $s2, matrix_two #Grab starting address of matrix two
	li $s3, 4 #Scale by which to traverse both matrices
	
	li $v0, 4
	la $a0, prompt #Ask for the user generated randomized seed
	syscall
	
	li $v0, 5 #Grab the randomized seed from the user
	move $s5, $v0 #Save the user-generated randomized seed
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $s4, 1024 #Initialize the offset counter
	
	#initialize the temporary counter
	move $t1, $zero #counter for 1st matrix
	move $t2, $zero #counter for 2nd matrix
	
	move $s6, $zero #Reserved column index.
	move $s7, $zero #Reserved row index. 
	
	
	
load_one: #t7 temporarily holds the difference of the offset and the counter
	sub  $t7, $s4, $t1
	
	#if $t7 == 0 branch to load_two
	beqz $t7, load_two #switch jump back to load two after debugging
	
	#else generate the next random integer and add it to the correct memory location
	###########RANDOM_NUMBER_GENERATOR#########################################
	move $a1, $s5
	li $v0, 42
	syscall
	move $t3, $v0
	###########RANDOM_NUMBER_GENERATOR#########################################
	
	add $t4, $s1, $t1 #generates the correct offset at which to store the random number in $t3
	sw $t3, 0($t4)   #EXTRA 12 digits is being added in here.
	
	#After storing value the pointer to the first element is updated by 4
	add $t1, $t1, $s3
	j load_one
		
load_two: #t7 temporarily holds the difference of the offset and the counter
	sub  $t7, $s4, $t2
	
	#if $t7 == 0 branch to print_input_one
	beqz $t7, print_input_one 
	
	#else generate the next random integer and add it to the correct memory location
	###########RANDOM_NUMBER_GENERATOR#########################################
	move $a1, $s5
	li $v0, 42
	syscall
	move $t3, $v0
	###########RANDOM_NUMBER_GENERATOR#########################################
	
	add $t4, $s2, $t2 #generates the correct offset at which to store the random number in $t3
	sw $t3, ($t4)	#EXTRA 12 digits is being added in here.
	
	#After storing value the pointer to the first element is updated by 4
	add $t2, $t2, $s3
	j load_two
	
print_input_one:

	#################################PRINT_ROUTINE#########################################################
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, m_label_one
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#################################PRINT_ROUTINE#########################################################
	
	li $t0, 64 #mod operand for determining line breaks (16 units * 4 bytes)
	
	la $s1, matrix_one #Grab starting address of matrix one
	move $s6, $zero #Row (Y) index that will be incremented every time a new line is printed
	move $s7, $zero #Column (X) index that will incremented every time and reset when a new line is printed.
	
	li $t5, 0 #A temporary counter variable
# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base 
	
itr_one: 
	sub  $t2, $s4, $t5 #need to subtract index instead of counter
	beqz $t2, print_input_two #branch to print_input_two ###END IF DEBUGGING

	# Else, check the modulus operation 
	div $t5, $t0 
	mfhi $t3
	
	bnez $t3, cont #If remainder is not zero continue past newline jump
	
	###################NEW_LINE######################################################										
	li $v0, 4 #New line printed every 16 entries					#
	la $a0, new_line 								#
	li $s7, 0 #Set Column Counter back to 0						#			
	syscall 									#
	###################NEW_LINE######################################################	
cont:	#calculate correct offset using the row major formula
	li $t3, 16 #loads num of columns into temp register
	mult $t3, $s7
	mfhi $t3
	add $t3, $t3, $s6
	sll $t3, $t3, 2 #Multiply by size of the data type (4 bytes)
	
	#add generated offset to the base address
	la $t4, matrix_one
	add $t4, $t4, $t3
	
	#Load the data located at the memory address stored in $t4 and place it in $t3
	lw $t3, ($t4)
	
	#################################PRINT_ROUTINE#########################################################
	li $v0, 1 
	move $a0, $t3 
	syscall #Print the value at the index to the screen
	
	li $v0, 4
	la $a0, space
	syscall #Print a space to the screen
	
	addi $s7, $s7, 1 #Increment the Column Counter by 1
	addi $s6, $s6, 1 #Increment the Row counter
	#################################PRINT_ROUTINE#########################################################
	addi $t5, $t5, 4
	j itr_one

print_input_two:

    	#################################PRINT_ROUTINE#########################################################
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, m_label_two
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#################################PRINT_ROUTINE#########################################################
	
	li $t0, 64 #mod operand for determining line breaks (16 units * 4 bytes)
	
	la $s2, matrix_two #Grab starting address of matrix two
	move $s6, $zero #Row (Y) index that will be incremented every time a new line is printed
	move $s7, $zero #Column (X) index that will incremented every time and reset when a new line is printed.
	
	li $t5, 0 #A temporary counter variable
	
# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base 

itr_two:
	sub  $t2, $s4, $t5 #need to subtract index instead of counter
	beqz $t2, conduct_operation #branch to print_input_two ###END IF DEBUGGING

	# Else, check the modulus operation 
	div $t5, $t0 
	mfhi $t3
	
	bnez $t3, cont_2 #If remainder is not zero continue past newline jump
	
	###################NEW_LINE######################################################										
	li $v0, 4 #New line printed every 16 entries					#
	la $a0, new_line 								#
	li $s7, 0 #Set Column Counter back to 0						#	
	syscall 									#
	###################NEW_LINE######################################################	
cont_2:	#calculate correct offset using the row major formula
	li $t3, 16 #loads num of columns into temp register
	mult $t3, $s7
	mfhi $t3
	add $t3, $t3, $s6
	sll $t3, $t3, 2 #Multiply by size of the data type (4 bytes)
	
	#add generated offset to the base address
	la $t4, matrix_two
	add $t4, $t4, $t3
	
	#Load the data located at the memory address stored in $t4 and place it in $t3
	lw $t3, ($t4)
	
	#################################PRINT_ROUTINE#########################################################
	li $v0, 1 
	move $a0, $t3 
	syscall #Print the value at the index to the screen
	
	li $v0, 4
	la $a0, space
	syscall #Print a space to the screen
	
	addi $s7, $s7, 1 #Increment the Column Counter by 1
	addi $s6, $s6, 1 #Increment the Row counter
	#################################PRINT_ROUTINE#########################################################
	addi $t5, $t5, 4
	j itr_two
		
	
conduct_operation:

	la $t0, matrix_one
	la $t1, matrix_two





end:



	
		
				
