.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	# store
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	beq	$a2, '+', au_normal_add
	beq	$a2, '-', au_normal_sub
	beq	$a2, '*', au_normal_mul
	beq	$a2, '/', au_normal_div
	j	au_normal_return
	
au_normal_add:
	add	$t0, $a0, $a1
	move	$v0, $t0
	j	au_normal_return
	
au_normal_sub:
	sub	$t0, $a0, $a1
	move	$v0, $t0
	j	au_normal_return
	
au_normal_mul:
	mult   $a0, $a1
	mflo	$v0
	mfhi	$v1
	j	au_normal_return
	
au_normal_div:
	div   	$a0, $a1
	mflo	$v0	
	mfhi	$v1
	j	au_normal_return
	
au_normal_return:
	# restore
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
