.data
prompt: 	.asciiz "Enter an integer for computing n!:"
n_display:	.asciiz "The integer is: "
fact_display:	.asciiz "The factorial of input is:"
new_line: 	.asciiz "\n"

.text
main:
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	# factorial value will be s1
	li $s1, 1
	
	# index value will be s2
	la $s2, ($t0)
	
	# decrement value of 1 at $s3
	li $s3, 1
	
factorial_loop:
	beqz $s2, end
	mult $s1, $s2
	mflo $s1
	sub $s2, $s2, $s3
	
	j factorial_loop
	
	
end:
	li $v0, 4
	la $a0, fact_display
	syscall
	
 	li $v0, 1
 	move $a0, $s1
 	syscall  
 	
 	li $v0, 4
	la $a0, new_line
	syscall

	
	
	
		
	
	
	
