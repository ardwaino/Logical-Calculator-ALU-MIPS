.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	# store
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	beq	$a2, '+', add_logical
	beq	$a2, '-', sub_logical
	beq	$a2, '*', mul_signed
	beq	$a2, '/', div_signed
	j	au_logical_return
	
# ------------------------------------------------------------add/sub
add_sub_logical: 
	extract_nth_bit($t0, $a0, $s0)				
	extract_nth_bit($t1, $a1, $s0)		

	xor	$t2, $t0, $t1			
	xor	$t3, $t2, $a2			

	and	$t4, $t0, $t1			
	and	$t5, $t2, $a2						
	or	$a2, $t4, $t5			

	la	$v1, ($a2)			
	insert_to_nth_bit($v0, $s0, $t3, $t9)	
	addi	$s0, $s0, 1			
	bne  	$s0, 32, add_sub_logical	
	jr	$ra
	
add_logical:
	# store
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	# pre add/sub logical
	la	$s0, ($zero)		
	la	$v0, ($zero)		
	la	$a2, ($zero)

	jal	add_sub_logical	
	
	# restore
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
sub_logical:
	# store
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	# pre add/sub logical
	la	$s0, ($zero)		
	la	$v0, ($zero)		
	la	$a2, ($zero)		
	not	$a2, $a2			
	not	$a1, $a1
			
	jal	add_sub_logical
	
	# restore
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
#------------------------------------------------------------twos comp
twos_complement:
	#store
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	
	not	$a0, $a0		
	la	$a1, ($zero)		
	li	$a1, 1	
	jal	add_logical
	
	#restore
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
	
twos_complement_if_neg:
	# Store 
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	blt	$a0, $zero, twos_complement_negative	
	j	twos_complement_positive
	
twos_complement_negative:
	jal	twos_complement		
	la	$a0, ($v0)		 
	
twos_complement_positive:
	la	$v0, ($a0)		
	# Restore
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
twos_complement_64bit:
	# store
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28

	not	$a0, $a0		
	not	$a1, $a1
	la	$s0, ($a1)		
	li	$a1, 1			 
	jal	add_logical			
	la	$s1, ($v0)		  
	la	$a0, ($v1)			
	la	$a1, ($s0)		
	jal	add_logical		
	la	$v1, ($v0)		 
	la	$v0, ($s1)
	
	# restore	
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
#------------------------------------------------------------bit rep
bit_replicator:	
	# store
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	bnez	$a0, bit_replicator_inverse	
	la	$v0, ($zero)			
	j	bit_replicator_end
	
bit_replicator_inverse:
	la	$v0, ($zero)			
	not	$v0, $v0
	
bit_replicator_end:
	# restore	
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
#------------------------------------------------------------mult
mul_unsigned:
	# store
	addi	$sp, $sp, -48
	sw	$fp, 48($sp)
	sw 	$ra, 44($sp)
	sw	$a0, 40($sp)
	sw	$a1, 36($sp)
	sw	$a2, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 48
	
	# prep mul_unsigned_loop	
	la	$s0, ($zero)			
	la	$s1, ($zero)			
	la	$s3, ($a1)			
	la	$s2, ($a0)			
	
mul_unsigned_loop:

	extract_nth_bit($t4, $s3, $zero)	
	la 	$a0, ($t4)			
	jal	bit_replicator
	la	$s4, ($v0)			
	and	$s5, $s2, $s4			

	la	$a0, ($s5)			 
	la	$a1, ($s1)			
	jal	add_logical
	la	$s1, ($v0)			
	srl	$s3, $s3, 1			
	extract_nth_bit($t7, $s1, $zero)		
	li	$t8, 31					
	insert_to_nth_bit($s3, $t8, $t7, $t9)	
	srl	$s1, $s1, 1			
	addi	$s0, $s0, 1			
	bne  	$s0, 32, mul_unsigned_loop	
	la	$v0, ($s3)			
	la	$v1, ($s1)			
	
	# restore	
	lw	$fp, 48($sp)
	lw 	$ra, 44($sp)
	lw	$a0, 40($sp)
	lw	$a1, 36($sp)
	lw	$a2, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 48
	jr	$ra
	
mul_signed:	
	
	# store
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
	
	la	$s0, ($a0)			
	la	$s1, ($a1)			
	la	$s2, ($a0)				
	la	$s3, ($a1)
				
	# args -> 2's complement
	jal	twos_complement_if_neg		
	la	$s2, ($v0)			
	la	$a0, ($s3)			
	jal	twos_complement_if_neg
	la	$s3, ($v0)		
		
	# prep for mult
	la	$a0, ($s2)			 
	la	$a1, ($s3)	
			
	# mult
	jal	mul_unsigned			
	la	$a0, ($v0)			
	la	$a1, ($v1)	
			
	# find sign of resultant value
	li	$t2, 31		
	extract_nth_bit($t0, $s0, $t2)		
	extract_nth_bit($t1, $s1, $t2)		
	xor	$t3, $t0, $t1 	 		
	bne	$t3, 1, mul_signed_end		
	jal	twos_complement_64bit
	
mul_signed_end:
	# restore	
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
#------------------------------------------------------------div
div_unsigned:
	# store
	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw 	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$a2, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 44
	
	# prep for div_unsigned_loop
	la	$s0, ($zero)			
	la	$s1, ($zero)			
	la	$s2, ($a0)			
	la	$s3, ($a1)			
	
div_unsigned_loop:	
	sll	$s1, $s1, 1			
	li	$t0, 31			
	extract_nth_bit($t1, $s2, $t0)		
	insert_to_nth_bit($s1, $zero, $t1, $t9)	
	sll	$s2, $s2, 1			
	la	$a0, ($s1)			
	la	$a1, ($s3)			
	jal	sub_logical
	la	$s4, ($v0)			
	blt	$s4, $zero, div_loop_end 	
	la	$s1, ($s4)			
	li	$t2, 1
	insert_to_nth_bit($s2, $zero, $t2, $t9)
	
div_loop_end:
	addi	$s0, $s0, 1			
	bne	$s0, 32, div_unsigned_loop	
	la	$v0, ($s2)			
	la	$v1, ($s1)
				
	# restore
	lw	$fp, 44($sp)
	lw 	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$a2, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
	
div_signed:

	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 44
	
	la	$s0, ($a0)			
	la	$s1, ($a1)			
	la	$s2, ($a0)				
	la	$s3, ($a1)			

	jal	twos_complement_if_neg		
	la	$s2, ($v0)			
	la	$a0, ($s3)			
	jal	twos_complement_if_neg
	la	$s3, ($v0)			

	la	$a0, ($s2) 			
	la	$a1, ($s3)			

	jal	div_unsigned			 	
	la	$a0, ($v0)			 
	la	$a1, ($v1)			

	li	$t2, 31
	extract_nth_bit($t0, $s0, $t2)		
	extract_nth_bit($t1, $s1, $t2)		
	xor	$t3, $t0, $t1			
	la	$s4, ($a0)			
	la	$s5, ($a1)			
	bne	$t3, 1, div_remainder_sign	
	jal	twos_complement
	la	$s4, ($v0)			
	
div_remainder_sign:	
	li	$t1, 31
	extract_nth_bit($t0, $s0, $t1)		
	la	$t2, ($t0)			
	bne	$t2, 1, div_signed_end		
	la	$a0, ($s5)			 
	jal	twos_complement
	la	$s5, ($v0)			
	
div_signed_end:	
	la	$v0, ($s4)	
	la	$v1, ($s5)	
	
	# restore
	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
	
au_logical_return:
	# restore
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$fp, $sp, 24
	jr 	$ra