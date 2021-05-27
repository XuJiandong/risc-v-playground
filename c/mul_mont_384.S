.text

.globl	mul_mont_384
.align 4
mul_mont_384:
	addi	sp,sp,-112
	ld	a5,0(a2)
	sd	s3,80(sp)
	sd	s4,72(sp)
	ld	s3,0(a1)
	ld	s4,8(a1)
	sd	a4,8(sp)
	mulhu	a6,s3,a5
	sd	s7,48(sp)
	addi	s7,a2,8
	addi	a2,a2,48
	sd	a2,0(sp)
	sd	s2,88(sp)
	ld	s2,16(a1)
	ld	t2,40(a1)
	sd	s0,104(sp)
	sd	s1,96(sp)
	ld	s1,24(a1)
	ld	s0,32(a1)
	sd	s9,32(sp)
	sd	s10,24(sp)
	sd	s11,16(sp)
	mv	s11,a0
	sd	s8,40(sp)
	sd	s5,64(sp)
	sd	s6,56(sp)

	mulhu	a2,a5,s4
	mul	a4,a5,s4

	add	a1,a4,a6
	sltu	s9,a1,a4
	ld	t4,0(a3)
	ld	s6,8(a3)
	ld	s5,16(a3)
	ld	t0,24(a3)
	ld	t6,32(a3)
	ld	t5,40(a3)
	li	a7,0
	add	s9,s9,a2

	mulhu	a2,a5,s2
	mul	a4,a5,s2

	add	s9,a4,s9
	sltu	t3,s9,a4

	add	t3,t3,a2

	mulhu	a2,a5,s1
	mul	a4,a5,s1

	add	t3,a4,t3
	sltu	a6,t3,a4
	add	a6,a6,a2

	mulhu	a2,a5,s0
	mul	a4,a5,s0

	add	a6,a4,a6
	sltu	a4,a6,a4
	mul	s10,a5,t2
	add	a4,a4,a2
	mul	a0,s3,a5
	add	t1,s10,a4
	ld	a4,8(sp)
	sltu	s8,t1,s10
	sd	a3,8(sp)
	ld	s10,0(sp)
	sd	s11,0(sp)
	mv	s11,a4
	mulhu	a5,a5,t2
	mul	a2,a0,a4
	add	s8,s8,a5
	j	.L298
.L300:
	ld	a3,0(s7)
	addi	s7,s7,8

	mulhu	s8,s3,a3
	mul	t1,s3,a3

	add	a0,t1,a0
	sltu	t1,a0,t1
	add	t1,t1,s8

	mulhu	s9,a3,s4
	mul	t3,a3,s4

	add	a1,t3,a1
	sltu	t3,a1,t3
	add	a1,t1,a1
	sltu	t1,a1,t1

	add	t3,t3,s9
	add	t3,t1,t3

	mulhu	t1,a3,s2
	mul	s8,a3,s2
	add	a4,s8,a4

	add	s9,t3,a4
	sltu	a4,a4,s8
	sltu	t3,s9,t3
	add	a4,a4,t1
	add	a4,t3,a4

	mulhu	t1,a3,s1
	mul	s8,a3,s1

	add	a5,s8,a5
	add	t3,a4,a5
	sltu	a5,a5,s8
	sltu	a4,t3,a4
	add	a5,a5,t1
	add	a4,a4,a5

	mulhu	t1,a3,s0
	mul	s8,a3,s0

	add	a5,s8,a6
	add	a6,a4,a5
	sltu	a5,a5,s8
	sltu	a4,a6,a4
	
	add	a5,a5,t1
	add	a4,a4,a5
    # can' change the order, because a3 <- a3 * t2
    mul	s8,a3,t2
	mulhu	a3,a3,t2

	add	a2,s8,a2
	add	t1,a4,a2
	sltu	s8,a2,s8
	sltu	a4,t1,a4
	mul	a2,s11,a0
	add	s8,s8,a3
	add	a4,a4,s8
	add	s8,a7,a4
	sltu	a7,s8,a7
.L298:
	add	a3,s8,a7
	sltu	a7,a3,s8

	mul	a4,a2,t4
	add	a0,a4,a0

	mulhu	s8,a2,s6
	mul	a5,a2,s6
	sltu	a0,a0,a4
    # share same rd with "mul a4,a2,t4"
	mulhu	a4,a2,t4
	add	a1,a5,a1
	sltu	a5,a1,a5
    
	add	a0,a0,a4
	add	a0,a1,a0
	sltu	a1,a0,a1
	add	a5,a5,s8
	add	a1,a1,a5

	mulhu	s8,a2,s5
	mul	a4,a2,s5

	add	s9,a4,s9
	sltu	a4,s9,a4
	add	a1,s9,a1
	sltu	s9,a1,s9
	add	a4,a4,s8
	add	a4,s9,a4

	mulhu	s8,a2,t0
	mul	a5,a2,t0

	add	t3,a5,t3
	sltu	a5,t3,a5
	add	a4,t3,a4
	sltu	t3,a4,t3
	add	a5,a5,s8
	add	a5,t3,a5

	mulhu	t3,a2,t6
	mul	s9,a2,t6

	add	a6,s9,a6
	sltu	s9,a6,s9
	add	a5,a6,a5
	sltu	a6,a5,a6
	
    mul	s8,a2,t5
	add	s9,s9,t3
	add	a6,a6,s9
	mulhu	a2,a2,t5

	add	t1,s8,t1
	sltu	s8,t1,s8
	add	a6,t1,a6
	sltu	t1,a6,t1
	add	a2,s8,a2
	add	a2,t1,a2
	add	a2,a3,a2
	sltu	a3,a2,a3
	add	a7,a3,a7
	bne	s10,s7,.L300
	ld	s11,0(sp)
	ld	a3,8(sp)
	sub	t4,a0,t4
	sd	t4,0(s11)
	ld	t3,8(a3)
	sgtu	t2,t4,a0
	xor	a0,t4,a0
	sub	t3,a1,t3
	sub	t2,t3,t2
	sd	t2,8(s11)
	ld	t1,16(a3)
	sgtu	t6,t3,a1
	sgtu	t3,t2,t3
	sub	t3,t6,t3
	sub	t1,a4,t1
	andi	t6,t3,1
	sub	t6,t1,t6
	sd	t6,16(s11)
	ld	t3,24(a3)
	sgtu	t5,t1,a4
	sgtu	t1,t6,t1
	sub	t1,t5,t1
	sub	t3,a5,t3
	andi	t5,t1,1
	sub	t5,t3,t5
	sd	t5,24(s11)
	ld	t1,32(a3)
	sgtu	t0,t3,a5
	sgtu	t3,t5,t3
	sub	t3,t0,t3
	sub	t1,a6,t1
	andi	t3,t3,1
	sub	t3,t1,t3
	sd	t3,32(s11)
	ld	a3,40(a3)
	sgtu	t0,t1,a6
	sgtu	t1,t3,t1
	sub	t1,t0,t1
	sub	a3,a2,a3
	andi	t0,t1,1
	sub	t0,a3,t0
	sgtu	t1,a3,a2
	sgtu	a3,t0,a3
	sub	a3,t1,a3
	andi	a3,a3,1
	sub	a7,a7,a3
	xor	a4,t6,a4
	xor	a3,t5,a5
	xor	a2,t0,a2
	xor	a1,t2,a1
	xor	a6,t3,a6
	ld	s0,104(sp)
	and	t1,a4,a7
	and	a5,a2,a7
	and	a0,a0,a7
	and	a1,a1,a7
	and	a3,a3,a7
	and	a4,a6,a7
	xor	t4,a0,t4
	xor	a1,a1,t2
	xor	a2,t1,t6
	xor	a3,a3,t5
	xor	a4,a4,t3
	xor	a5,a5,t0
	sd	t4,0(s11)
	sd	a1,8(s11)
	sd	a2,16(s11)
	sd	a3,24(s11)
	sd	a4,32(s11)
	sd	a5,40(s11)
	ld	s1,96(sp)
	ld	s2,88(sp)
	ld	s3,80(sp)
	ld	s4,72(sp)
	ld	s5,64(sp)
	ld	s6,56(sp)
	ld	s7,48(sp)
	ld	s8,40(sp)
	ld	s9,32(sp)
	ld	s10,24(sp)
	ld	s11,16(sp)
	addi	sp,sp,112
	jr	ra
	.size	mul_mont_384, .-mul_mont_384
.LC0:
	.dword	157587932685088877
