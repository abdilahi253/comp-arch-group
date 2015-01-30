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
m_label_prod:	.asciiz "Matrix Product"
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
	
	#call for matrix 2 transpose found in print_input_2 method
	
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
	
	la	$a0, matrix_two	# Setting up parameters for transpose method
	li	$a1, 16		# matrix size
	jal 	transpose	# Comment this out for Row Major format
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

	la $s0, matrix_one
	la $s1, matrix_two
	la $s2, matrix_product

	li $t1, 16	# number of cols
	li $t0, 0 	# overall counter
	li $t2, 0	# local row counter
	li $t5, 0	# local col counter
	
	move $t3, $zero	# use for matrix 1 value
	move $t4, $zero # use for matrix 2 value
	
	
	move $s3, $zero	# use for storing value to move to memory
	
	#Free registers = s4, s5, s6, s7, t6, t7
	
Beg:
	addi	$t7, $t0, -16
	beqz 	$t7, print_matrix_product
	
Row_Loop:
	#find matrix 1 value
	mult     $t1, $t0       # mult overall count * # cols
        mflo     $t6            # move result to t6
        add      $t6, $t6, $t2  # result += local counter
        sll      $t6, $t6, 2    # shift for offset, save this for offset in product matrix
        add	 $t7, $t6, $s0
        lw	 $t3, ($t7)	# save matrix 1 value in t3
        #add	 $s4, $t6, $zero#save offset in s4
        
        #find matrix 2 value
        mult	$t2, $t1	# mult # of cols * local counter
        mflo	$t6		# move result to t6
        add	$t6, $t6, $t5	# result += col counter
        sll	$t6, $t6, 2
        add	$t7, $s1, $t6
        lw	$t4, ($t7)	# save matrix 2 value in t4
        
        mult	$t3, $t4	# multiply the two values
        mflo	$t7		# grab mult result
        add	$s3, $s3, $t7	# add new result to existing ongoing row/col mult
        
	
	addi	$t2, $t2, 1	# increment local counter
	addi	$t7, $t2, -16	
	bnez	$t7, Row_Loop	# for check to see if we are at end of mult sequence for one set of row/col
	
	#else we are at end of mult seq. need to store result
	#Locate index in product matrix
	mult	$t0, $t1
	mflo	$t6
	add	$t6, $t6, $t5	# add col counter this time to find element in product matrix
	sll	$t6, $t6, 2
	
	add	$t7, $s2, $t6
	sw	$s3, ($t7)	# else : we are at end of mult seq, need to store result
	move	$s3, $zero	# reset running total
	move	$t2, $zero	# reset local counter
	
	addi	$t5, $t5, 1	# increment col counter
	addi	$t7, $t5, -16
	bnez	$t7, Row_Loop	# if we have not finished mult each col by the row in question
	
	move 	$t5, $zero	# else reset col counter for the move to next row of multiplication
	
	addi	$t0, $t0, 1	# increment overall counter (move on to next row/col pair)
	j	Beg
	
	
print_matrix_product:

    	#################################PRINT_ROUTINE#########################################################
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, m_label_prod
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#################################PRINT_ROUTINE#########################################################
	
	li $t0, 64 #mod operand for determining line breaks (16 units * 4 bytes)
	
	la $s2, matrix_product #Grab starting address of matrix two
	move $s6, $zero #Row (Y) index that will be incremented every time a new line is printed
	move $s7, $zero #Column (X) index that will incremented every time and reset when a new line is printed.
	
	li $t5, 0 #A temporary counter variable
	
# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base 

itr_product:
	sub  $t2, $s4, $t5 #need to subtract index instead of counter
	beqz $t2, end #branch to end ###END IF DEBUGGING

	# Else, check the modulus operation 
	div $t5, $t0 
	mfhi $t3
	
	bnez $t3, cont_product #If remainder is not zero continue past newline jump
	
	###################NEW_LINE######################################################										
	li $v0, 4 #New line printed every 16 entries					#
	la $a0, new_line 								#
	li $s7, 0 #Set Column Counter back to 0						#	
	syscall 									#
	###################NEW_LINE######################################################	
cont_product:	#calculate correct offset using the row major formula
	li $t3, 16 #loads num of columns into temp register
	mult $t3, $s7
	mfhi $t3
	add $t3, $t3, $s6
	sll $t3, $t3, 2 #Multiply by size of the data type (4 bytes)
	
	#add generated offset to the base address
	la $t4, matrix_product
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
	j itr_product
	
	
	
end:

	li       $v0, 10        # system service 10 is exit
        syscall


transpose:
	#a0 = matrix base address, a1 = matrix size
	add	$t0, $zero, $zero # overall counter
	add	$t1, $zero, $zero #row iteration counter
	
inner_loop:
	beq	$t0, $a1, return_transpose
	beq	$t1, $a1, inc_overall
	mult	$a1, $t0	# find row position
	mfhi	$t2
	add	$t2, $t2, $t1
	sll	$t2, $t2, 2
	add	$t2, $t2, $a0	# t2 holds address of where to put swapped int from t5
	lw	$t4, 0($t2)	# store in temp variable for swap
	
	mult	$a1, $t1	# find col position
	mfhi	$t3
	add	$t3, $t3, $t0
	sll	$t3, $t3, 2
	add	$t3, $t3, $a0	# t3 holds address of where to put swapped int from t4
	lw	$t5, 0($t3)	# temp variable for swap
	
	sw	$t4, 0($t3)	#perform swap
	sw	$t5, 0($t2)
	
	addi	$t1, $t1, 1	#increment row counter
	j	inner_loop
	
inc_overall:

	addi	$t0, $t0, 1	#increment overall counter
	add	$t1, $t0, $zero #reset row counter, but shift to handle diagonal and avoid reswaps
	j	inner_loop
		
			
return_transpose:

	jr 	$ra	#return
				
