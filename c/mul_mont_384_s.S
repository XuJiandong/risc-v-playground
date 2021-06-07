	.align	1
	.globl	mul_mont_384
	.hidden	mul_mont_384
	.type	mul_mont_384, @function
mul_mont_384:
	ld	t4,0(a2)
	addi	sp,sp,-112
	sd	s0,104(sp)
	sd	s1,96(sp)
	sd	s2,88(sp)
	sd	s3,80(sp)
	sd	s4,72(sp)
	li	a6,0
	li	a5,0
	addi	t3,sp,8
	li	t5,48
.L134:
	add	a7,a1,a6
	ld	a7,0(a7)
	add	t6,t3,a6
	addi	a6,a6,8

	mulhu	a7,t4,a7
	mul	t1,t4,a7

	add	a5,t1,a5
	sltu	t1,a5,t1
	sd	a5,0(t6)
	add	a5,t1,a7
	bne	a6,t5,.L134
	ld	s0,8(sp)
	ld	t5,0(a3)
	addi	t4,a2,8
	mul	s0,a4,s0
	sd	a5,56(sp)
	addi	a2,a2,48
	li	t2,0
	addi	t6,a3,48
	addi	t0,a1,48
.L138:
	ld	a7,8(sp)
	addi	s1,a3,8
	mv	s2,t3

	mulhu	a5,s0,t5
	mul	a6,s0,t5

	mv	t1,a6
	add	a6,a6,a7
	sltu	a6,a6,t1
	mv	a7,t3
	add	a5,a6,a5
.L135:
	ld	a6,0(s1)
	ld	s4,8(s2)
	addi	s1,s1,8

	addi	s2,s2,8

	mulhu	t1,s0,a6
	mul	s3,s0,a6

	add	a6,s4,a5
	sltu	a5,a6,s4
	add	a6,s3,a6
	sltu	s3,a6,s3
	sd	a6,-8(s2)
	add	t1,t1,a5
	add	a5,s3,t1
	bne	t6,s1,.L135
	ld	t1,56(sp)
	add	a6,t1,t2
	add	a5,a6,a5
	sltu	t2,a6,t1
	sd	a5,48(sp)
	sltu	a6,a5,a6
	add	t2,a6,t2
	beq	a2,t4,.L140
	ld	s3,0(t4)
	mv	s0,a1
	li	a5,0
.L137:
	ld	a6,0(s0)
	ld	s2,0(a7)
	addi	s0,s0,8
	addi	a7,a7,8

	mulhu	t1,s3,a6
	mul	s1,s3,a6

	add	a6,s2,a5
	sltu	a5,a6,s2
	add	a6,s1,a6
	sltu	s1,a6,s1
	sd	a6,-8(a7)
	add	a5,t1,a5
	add	a5,s1,a5
	bne	t0,s0,.L137
	ld	s0,8(sp)
	add	a5,t2,a5
	sd	a5,56(sp)
	mul	s0,a4,s0
	sltu	t2,a5,t2
	addi	t4,t4,8
	j	.L138
.L140:
	li	a2,0
	li	a4,0
	li	a6,48
.L136:
	add	a5,t3,a2
	ld	a1,0(a5)
	add	a5,a3,a2
	ld	a5,0(a5)
	sub	a4,a1,a4
	sgtu	a1,a4,a1
	sub	a5,a4,a5
	sgtu	a4,a5,a4
	sub	a4,a1,a4
	add	a1,a0,a2
	sd	a5,0(a1)
	addi	a2,a2,8
	andi	a4,a4,1
	bne	a2,a6,.L136
	sub	a4,t2,a4
	addi	a2,a0,48
.L139:
	ld	a5,0(a0)
	ld	a3,0(a7)
	addi	a0,a0,8
	addi	a7,a7,8
	xor	a3,a5,a3
	and	a3,a3,a4
	xor	a3,a3,a5
	sd	a3,-8(a0)
	bne	a2,a0,.L139
	ld	s0,104(sp)
	ld	s1,96(sp)
	ld	s2,88(sp)
	ld	s3,80(sp)
	ld	s4,72(sp)
	addi	sp,sp,112
	jr	ra
	.size	mul_mont_384, .-mul_mont_384
