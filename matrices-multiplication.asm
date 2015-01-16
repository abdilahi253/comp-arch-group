.data
matrix_one:	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
matrix_two: 	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
row_index:	.word 0
column_index:	.word 0
offset:		.word 0
max_offset:	.word 1024 #Used as a flag variable for iterative loops in the matrix
prompt:		.asciiz "What seed would you like to give the matrix?:"
base:		.asciiz "Base Address: "
sum_address:	.asciiz "Generated Address: "
m_label_one:	.asciiz "Matrix One"
m_label_two:	.asciiz "Matrix Two"
space:		.asciiz " "
new_line: 	.asciiz "\n"

debug_one:	.asciiz "In Load 1st Matrix::DEBUG"
debug_two:	.asciiz "In Load 2nd Matrix::DEBUG"

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
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	move $s4, $v0 #Save the user-generated randomized seed
	move $t1, $zero #Initialize the offset counter for load_one (0)
	move $t7, $zero #Initialize the offset counter for load_two (0)
	
	move $s6, $zero #Reserved column index.
	move $s7, $zero #Reserved row index. 
	
load_one:
	li $t2, 1024
	sub  $t0, $t2, $t1
	
	beqz $t0, load_two #switch jump back to load two after debugging
	add $t3, $t0, $t2
	add $t4, $s1, $t1
	sw $t3, 0($t4)   #EXTRA 12 digits is being added in here.
	
	#################################DEBUG#################################################################
	lw $t3, 0($t4)
	li $v0, 1
	move $a0, $t3
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#################################DEBUG#################################################################
	
	
	#After storing value the pointer to the first element is updated by 4
	add $t1, $t1, $s3
	j load_one
		
load_two:
	li $t2, 1024
	sub  $t0, $t2, $t1
	
	beqz $t0, print_input_one #switch jump back to load two after debugging
	add $t3, $t0, $t2
	add $t4, $t4, $t1
	sw $t3, ($t4)
	#else continue loading matrix
	
	#After storing value the pointer to the first element is updated by 4
	add $t7, $t7, $s3
	j load_two
	
print_input_one:
	#print out a label string
	li $v0, 4
	la $a0, m_label_one
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $t0, 64 #mod operand for determining line breaks (16 units * 4 bytes)
	
	la $s1, matrix_one #Grab starting address of matrix one
	move $s6, $zero #Row (Y) index that will be incremented every time a new line is printed
	move $s7, $zero #Column (X) index that will incremented every time and reset when a new line is printed.
	la $t1, max_offset #$t1 loaded with max offset
	
# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base 
	
itr_one: 
	sub  $t2, $t1, $s1
	beqz $t2, end #branch to print_input_two
	
	#calculate correct offset using the above formula
	li $t3, 16 #loads num of columns into temp register
	mult $t3, $s7
	mfhi $t3
	add $t3, $t3, $s6
	sll $t3, $t3, 2 #Multiply by size of the data type (4 bytes)
	#add $s1, $s1, $t3
	
	#add generated offset to the base address
	la $t4, matrix_one
	add $t4, $t4, $t3
	
	#################################DEBUG#################################################################
	#print out a label string
	#li $v0, 4
	#la $a0, base
	#syscall 
	
	#li $v0, 1
	#move $a0, $s1
	#syscall
	
	#li $v0, 4
	#la $a0, new_line
	#syscall
	
	#print out a label string
	#li $v0, 4
	#la $a0, sum_address
	#syscall
	
	#li $v0, 1
	#move $a0, $t4
	#syscall
	
	#li $v0, 4
	#la $a0, new_line
	#syscall
	#################################DEBUG#################################################################
	
	#print out the data from the index.
	lw $t3, ($t4)
	
	#################################PRINT_ROUTINE#########################################################
	li $v0, 1 
	move $a0, $t3 
	syscall #Print the value at the index to the screen
	
	li $v0, 4
	la $a0, space
	syscall #Print a space to the screen
	
	div $s1, $t0 
	mfhi $t3
	bnez $t3, cont #If remainder is not zero continue past newline jump

	li $v0, 4
	la $a0, new_line 
	syscall #New line printed every 16 entries
	#################################PRINT_ROUTINE#########################################################
cont:	addi $s1, $s1, 4
	j itr_one
	

	
		
			
				
					
						
							
								
									
										
											
												
													
														
															
																	
print_input_two:
	#print out a label string
	li $v0, 4
	la $a0, m_label_two
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	la $s2, matrix_two #Grab starting address of matrix two
# Accesses will happen easiest if we utilize row-major order
# Example: size_of_data_type * (num_total_columns * x_coord + y_coord) = offset_from_base 
	
itr_two:
	la $t2, max_offset
	sub  $t0, $t2, $t1
	beqz $t0, conduct_operation
	
	
	#else print out the data from the index.
	
	
	
	
	j itr_two
		
	
conduct_operation:

	
iterate_one:
	




iterate_two:





end:



	
		
				
