.data
matrix_one:	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
matrix_two: 	.word 0 : 256 #1D Matrix, that we can traverse with row major manipulation
row_index:	.word 0
column_index:	.word 0
offset:		.word 0
max_offset:	.word 1024 #Used as a flag variable for iterative loops in the matrix
prompt:		.asciiz "What seed would you like to give the matrix?:"
m_label_one:	.asciiz "Matrix One"
m_label_two:	.asciiz "Matrix Two"
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
	move $t1, $zero #Initialize the offset counter
	
load_one:
	li $t2, 1024
	sub  $t0, $t2, $t1
	
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	li $v0, 4								
	la $a0, debug_one
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	
	
	beqz $t0, load_two
	add $t3, $t0, $t2
	sw $t3, matrix_one($s3)
	#else continue loading matrix
	
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	li $v0, 1								
	la $a0, offset     # This section is not actually conducting any operations
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	
	#After storing value the pointer to the first element is updated by 4
	add $s1, $s1, $s3
	j load_one
		
load_two:
	li $t2, 1024
	sub  $t0, $t2, $t1
	
	beqz $t0, load_two
	add $t3, $t0, $t2
	sw $t3, matrix_one($s3)
	#else continue loading matrix
	
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	li $v0, 4
	la $a0, debug_two
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	#DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG #DEBUG 
	
	#After storing value the pointer to the first element is updated by 4
	add $s2, $s2, $s3
	j end
	
print_input_one:
	#print out a label string
	li $v0, 4
	la $a0, m_label_one
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
itr_one:la $s1, matrix_one #Grab starting address of matrix one
	la $t2, max_offset
	sub  $t0, $t2, $t1
	beqz $t0, print_input_two
	
	
print_input_two:
	#print out a label string
	li $v0, 4
	la $a0, m_label_two
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall
	
itr_two:la $s2, matrix_two #Grab starting address of matrix two
	la $t2, max_offset
	sub  $t0, $t2, $t1
	beqz $t0, conduct_operation	
		
	
conduct_operation:

	
iterate_one:
	




iterate_two:





end:



	
		
				