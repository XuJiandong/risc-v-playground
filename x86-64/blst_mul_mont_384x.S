.globl	blst_mul_mont_384x
.hidden	blst_mul_mont_384x
.type	blst_mul_mont_384x,@function
.align	32
blst_mul_mont_384x:
	.byte	0xf3,0x0f,0x1e,0xfa

	pushq	%rbp
	pushq	%rbx
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	subq	$328,%rsp

	movq	%rdx,%rbx
	movq	%rdi,32(%rsp)
	movq	%rsi,24(%rsp)
	movq	%rdx,16(%rsp)
	movq	%rcx,8(%rsp)
	movq	%r8,0(%rsp)

	leaq	40(%rsp),%rdi
	call	__blst_mulq_384

	leaq	48(%rbx),%rbx
	leaq	48(%rsi),%rsi
	leaq	40+96(%rsp),%rdi
	call	__blst_mulq_384

	movq	8(%rsp),%rcx
	leaq	-48(%rsi),%rdx
	leaq	40+192+48(%rsp),%rdi
	call	__blst_add_mod_384

	movq	16(%rsp),%rsi
	leaq	48(%rsi),%rdx
	leaq	-48(%rdi),%rdi
	call	__blst_add_mod_384

	leaq	(%rdi),%rbx
	leaq	48(%rdi),%rsi
	call	__blst_mulq_384


	leaq	(%rdi),%rsi
	leaq	40(%rsp),%rdx
	movq	8(%rsp),%rcx
	call	__blst_sub_mod_384x384

	leaq	(%rdi),%rsi
	leaq	-96(%rdi),%rdx
	call	__blst_sub_mod_384x384


	leaq	40(%rsp),%rsi
	leaq	40+96(%rsp),%rdx
	leaq	40(%rsp),%rdi
	call	__blst_sub_mod_384x384

	movq	%rcx,%rbx


	leaq	40(%rsp),%rsi
	movq	0(%rsp),%rcx
	movq	32(%rsp),%rdi
	call	__blst_mulq_by_1_mont_384
	call	__blst_redc_tail_mont_384


	leaq	40+192(%rsp),%rsi
	movq	0(%rsp),%rcx
	leaq	48(%rdi),%rdi
	call	__blst_mulq_by_1_mont_384
	call	__blst_redc_tail_mont_384

	leaq	328(%rsp),%r8
	movq	0(%r8),%r15
	movq	8(%r8),%r14
	movq	16(%r8),%r13
	movq	24(%r8),%r12
	movq	32(%r8),%rbx
	movq	40(%r8),%rbp
	leaq	48(%r8),%rsp
	.byte	0xf3,0xc3


__blst_mulq_384:
	movq	0(%rbx),%rax

	movq	%rax,%rbp
	mulq	0(%rsi)
	movq	%rax,0(%rdi)
	movq	%rbp,%rax
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r11
	movq	8(%rbx),%rax
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rax,%rbp
	mulq	0(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rcx,8(%rdi)
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r8,%rcx
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r11
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r12
	movq	16(%rbx),%rax
	adcq	$0,%rdx
	addq	%r12,%r11
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rax,%rbp
	mulq	0(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rcx,16(%rdi)
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r8,%rcx
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r11
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r12
	movq	24(%rbx),%rax
	adcq	$0,%rdx
	addq	%r12,%r11
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rax,%rbp
	mulq	0(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rcx,24(%rdi)
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r8,%rcx
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r11
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r12
	movq	32(%rbx),%rax
	adcq	$0,%rdx
	addq	%r12,%r11
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rax,%rbp
	mulq	0(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rcx,32(%rdi)
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r8,%rcx
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r11
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r12
	movq	40(%rbx),%rax
	adcq	$0,%rdx
	addq	%r12,%r11
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rax,%rbp
	mulq	0(%rsi)
	addq	%rax,%rcx
	movq	%rbp,%rax
	adcq	$0,%rdx
	movq	%rcx,40(%rdi)
	movq	%rdx,%rcx

	mulq	8(%rsi)
	addq	%rax,%r8
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r8,%rcx
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rsi)
	addq	%rax,%r9
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rsi)
	addq	%rax,%r10
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rsi)
	addq	%rax,%r11
	movq	%rbp,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rsi)
	addq	%rax,%r12
	movq	%rax,%rax
	adcq	$0,%rdx
	addq	%r12,%r11
	adcq	$0,%rdx
	movq	%rdx,%r12
	movq	%rcx,48(%rdi)
	movq	%r8,56(%rdi)
	movq	%r9,64(%rdi)
	movq	%r10,72(%rdi)
	movq	%r11,80(%rdi)
	movq	%r12,88(%rdi)
	.byte	0xf3,0xc3

.type	__blst_add_mod_384,@function
.align	32
__blst_add_mod_384:
	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11
	movq	32(%rsi),%r12
	movq	40(%rsi),%r13

	addq	0(%rdx),%r8
	adcq	8(%rdx),%r9
	adcq	16(%rdx),%r10
	movq	%r8,%r14
	adcq	24(%rdx),%r11
	movq	%r9,%r15
	adcq	32(%rdx),%r12
	movq	%r10,%rax
	adcq	40(%rdx),%r13
	movq	%r11,%rbx
	sbbq	%rdx,%rdx

	subq	0(%rcx),%r8
	sbbq	8(%rcx),%r9
	movq	%r12,%rbp
	sbbq	16(%rcx),%r10
	sbbq	24(%rcx),%r11
	sbbq	32(%rcx),%r12
	movq	%r13,%rsi
	sbbq	40(%rcx),%r13
	sbbq	$0,%rdx

	cmovcq	%r14,%r8
	cmovcq	%r15,%r9
	cmovcq	%rax,%r10
	movq	%r8,0(%rdi)
	cmovcq	%rbx,%r11
	movq	%r9,8(%rdi)
	cmovcq	%rbp,%r12
	movq	%r10,16(%rdi)
	cmovcq	%rsi,%r13
	movq	%r11,24(%rdi)
	movq	%r12,32(%rdi)
	movq	%r13,40(%rdi)

	.byte	0xf3,0xc3


.type	__blst_sub_mod_384x384,@function
.align	32
__blst_sub_mod_384x384:
	.byte	0xf3,0x0f,0x1e,0xfa

	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11
	movq	32(%rsi),%r12
	movq	40(%rsi),%r13
	movq	48(%rsi),%r14

	subq	0(%rdx),%r8
	movq	56(%rsi),%r15
	sbbq	8(%rdx),%r9
	movq	64(%rsi),%rax
	sbbq	16(%rdx),%r10
	movq	72(%rsi),%rbx
	sbbq	24(%rdx),%r11
	movq	80(%rsi),%rbp
	sbbq	32(%rdx),%r12
	movq	88(%rsi),%rsi
	sbbq	40(%rdx),%r13
	movq	%r8,0(%rdi)
	sbbq	48(%rdx),%r14
	movq	0(%rcx),%r8
	movq	%r9,8(%rdi)
	sbbq	56(%rdx),%r15
	movq	8(%rcx),%r9
	movq	%r10,16(%rdi)
	sbbq	64(%rdx),%rax
	movq	16(%rcx),%r10
	movq	%r11,24(%rdi)
	sbbq	72(%rdx),%rbx
	movq	24(%rcx),%r11
	movq	%r12,32(%rdi)
	sbbq	80(%rdx),%rbp
	movq	32(%rcx),%r12
	movq	%r13,40(%rdi)
	sbbq	88(%rdx),%rsi
	movq	40(%rcx),%r13
	sbbq	%rdx,%rdx

	andq	%rdx,%r8
	andq	%rdx,%r9
	andq	%rdx,%r10
	andq	%rdx,%r11
	andq	%rdx,%r12
	andq	%rdx,%r13

	addq	%r8,%r14
	adcq	%r9,%r15
	movq	%r14,48(%rdi)
	adcq	%r10,%rax
	movq	%r15,56(%rdi)
	adcq	%r11,%rbx
	movq	%rax,64(%rdi)
	adcq	%r12,%rbp
	movq	%rbx,72(%rdi)
	adcq	%r13,%rsi
	movq	%rbp,80(%rdi)
	movq	%rsi,88(%rdi)

	.byte	0xf3,0xc3


.size	from_mont_384,.-from_mont_384
.type	__blst_mulq_by_1_mont_384,@function
.align	32
__blst_mulq_by_1_mont_384:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa

	movq	0(%rsi),%rax
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11
	movq	32(%rsi),%r12
	movq	40(%rsi),%r13

	movq	%rax,%r14
	imulq	%rcx,%rax
	movq	%rax,%r8

	mulq	0(%rbx)
	addq	%rax,%r14
	movq	%r8,%rax
	adcq	%rdx,%r14

	mulq	8(%rbx)
	addq	%rax,%r9
	movq	%r8,%rax
	adcq	$0,%rdx
	addq	%r14,%r9
	adcq	$0,%rdx
	movq	%rdx,%r14

	mulq	16(%rbx)
	addq	%rax,%r10
	movq	%r8,%rax
	adcq	$0,%rdx
	addq	%r14,%r10
	adcq	$0,%rdx
	movq	%rdx,%r14

	mulq	24(%rbx)
	addq	%rax,%r11
	movq	%r8,%rax
	adcq	$0,%rdx
	movq	%r9,%r15
	imulq	%rcx,%r9
	addq	%r14,%r11
	adcq	$0,%rdx
	movq	%rdx,%r14

	mulq	32(%rbx)
	addq	%rax,%r12
	movq	%r8,%rax
	adcq	$0,%rdx
	addq	%r14,%r12
	adcq	$0,%rdx
	movq	%rdx,%r14

	mulq	40(%rbx)
	addq	%rax,%r13
	movq	%r9,%rax
	adcq	$0,%rdx
	addq	%r14,%r13
	adcq	$0,%rdx
	movq	%rdx,%r14

	mulq	0(%rbx)
	addq	%rax,%r15
	movq	%r9,%rax
	adcq	%rdx,%r15

	mulq	8(%rbx)
	addq	%rax,%r10
	movq	%r9,%rax
	adcq	$0,%rdx
	addq	%r15,%r10
	adcq	$0,%rdx
	movq	%rdx,%r15

	mulq	16(%rbx)
	addq	%rax,%r11
	movq	%r9,%rax
	adcq	$0,%rdx
	addq	%r15,%r11
	adcq	$0,%rdx
	movq	%rdx,%r15

	mulq	24(%rbx)
	addq	%rax,%r12
	movq	%r9,%rax
	adcq	$0,%rdx
	movq	%r10,%r8
	imulq	%rcx,%r10
	addq	%r15,%r12
	adcq	$0,%rdx
	movq	%rdx,%r15

	mulq	32(%rbx)
	addq	%rax,%r13
	movq	%r9,%rax
	adcq	$0,%rdx
	addq	%r15,%r13
	adcq	$0,%rdx
	movq	%rdx,%r15

	mulq	40(%rbx)
	addq	%rax,%r14
	movq	%r10,%rax
	adcq	$0,%rdx
	addq	%r15,%r14
	adcq	$0,%rdx
	movq	%rdx,%r15

	mulq	0(%rbx)
	addq	%rax,%r8
	movq	%r10,%rax
	adcq	%rdx,%r8

	mulq	8(%rbx)
	addq	%rax,%r11
	movq	%r10,%rax
	adcq	$0,%rdx
	addq	%r8,%r11
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	16(%rbx)
	addq	%rax,%r12
	movq	%r10,%rax
	adcq	$0,%rdx
	addq	%r8,%r12
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	24(%rbx)
	addq	%rax,%r13
	movq	%r10,%rax
	adcq	$0,%rdx
	movq	%r11,%r9
	imulq	%rcx,%r11
	addq	%r8,%r13
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	32(%rbx)
	addq	%rax,%r14
	movq	%r10,%rax
	adcq	$0,%rdx
	addq	%r8,%r14
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	40(%rbx)
	addq	%rax,%r15
	movq	%r11,%rax
	adcq	$0,%rdx
	addq	%r8,%r15
	adcq	$0,%rdx
	movq	%rdx,%r8

	mulq	0(%rbx)
	addq	%rax,%r9
	movq	%r11,%rax
	adcq	%rdx,%r9

	mulq	8(%rbx)
	addq	%rax,%r12
	movq	%r11,%rax
	adcq	$0,%rdx
	addq	%r9,%r12
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	16(%rbx)
	addq	%rax,%r13
	movq	%r11,%rax
	adcq	$0,%rdx
	addq	%r9,%r13
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	24(%rbx)
	addq	%rax,%r14
	movq	%r11,%rax
	adcq	$0,%rdx
	movq	%r12,%r10
	imulq	%rcx,%r12
	addq	%r9,%r14
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	32(%rbx)
	addq	%rax,%r15
	movq	%r11,%rax
	adcq	$0,%rdx
	addq	%r9,%r15
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	40(%rbx)
	addq	%rax,%r8
	movq	%r12,%rax
	adcq	$0,%rdx
	addq	%r9,%r8
	adcq	$0,%rdx
	movq	%rdx,%r9

	mulq	0(%rbx)
	addq	%rax,%r10
	movq	%r12,%rax
	adcq	%rdx,%r10

	mulq	8(%rbx)
	addq	%rax,%r13
	movq	%r12,%rax
	adcq	$0,%rdx
	addq	%r10,%r13
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	16(%rbx)
	addq	%rax,%r14
	movq	%r12,%rax
	adcq	$0,%rdx
	addq	%r10,%r14
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	24(%rbx)
	addq	%rax,%r15
	movq	%r12,%rax
	adcq	$0,%rdx
	movq	%r13,%r11
	imulq	%rcx,%r13
	addq	%r10,%r15
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	32(%rbx)
	addq	%rax,%r8
	movq	%r12,%rax
	adcq	$0,%rdx
	addq	%r10,%r8
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	40(%rbx)
	addq	%rax,%r9
	movq	%r13,%rax
	adcq	$0,%rdx
	addq	%r10,%r9
	adcq	$0,%rdx
	movq	%rdx,%r10

	mulq	0(%rbx)
	addq	%rax,%r11
	movq	%r13,%rax
	adcq	%rdx,%r11

	mulq	8(%rbx)
	addq	%rax,%r14
	movq	%r13,%rax
	adcq	$0,%rdx
	addq	%r11,%r14
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	16(%rbx)
	addq	%rax,%r15
	movq	%r13,%rax
	adcq	$0,%rdx
	addq	%r11,%r15
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	24(%rbx)
	addq	%rax,%r8
	movq	%r13,%rax
	adcq	$0,%rdx
	addq	%r11,%r8
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	32(%rbx)
	addq	%rax,%r9
	movq	%r13,%rax
	adcq	$0,%rdx
	addq	%r11,%r9
	adcq	$0,%rdx
	movq	%rdx,%r11

	mulq	40(%rbx)
	addq	%rax,%r10
	movq	%r14,%rax
	adcq	$0,%rdx
	addq	%r11,%r10
	adcq	$0,%rdx
	movq	%rdx,%r11
	.byte	0xf3,0xc3

.type	__blst_sub_mod_384x384,@function
.align	32
__blst_sub_mod_384x384:
	.byte	0xf3,0x0f,0x1e,0xfa

	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11
	movq	32(%rsi),%r12
	movq	40(%rsi),%r13
	movq	48(%rsi),%r14

	subq	0(%rdx),%r8
	movq	56(%rsi),%r15
	sbbq	8(%rdx),%r9
	movq	64(%rsi),%rax
	sbbq	16(%rdx),%r10
	movq	72(%rsi),%rbx
	sbbq	24(%rdx),%r11
	movq	80(%rsi),%rbp
	sbbq	32(%rdx),%r12
	movq	88(%rsi),%rsi
	sbbq	40(%rdx),%r13
	movq	%r8,0(%rdi)
	sbbq	48(%rdx),%r14
	movq	0(%rcx),%r8
	movq	%r9,8(%rdi)
	sbbq	56(%rdx),%r15
	movq	8(%rcx),%r9
	movq	%r10,16(%rdi)
	sbbq	64(%rdx),%rax
	movq	16(%rcx),%r10
	movq	%r11,24(%rdi)
	sbbq	72(%rdx),%rbx
	movq	24(%rcx),%r11
	movq	%r12,32(%rdi)
	sbbq	80(%rdx),%rbp
	movq	32(%rcx),%r12
	movq	%r13,40(%rdi)
	sbbq	88(%rdx),%rsi
	movq	40(%rcx),%r13
	sbbq	%rdx,%rdx

	andq	%rdx,%r8
	andq	%rdx,%r9
	andq	%rdx,%r10
	andq	%rdx,%r11
	andq	%rdx,%r12
	andq	%rdx,%r13

	addq	%r8,%r14
	adcq	%r9,%r15
	movq	%r14,48(%rdi)
	adcq	%r10,%rax
	movq	%r15,56(%rdi)
	adcq	%r11,%rbx
	movq	%rax,64(%rdi)
	adcq	%r12,%rbp
	movq	%rbx,72(%rdi)
	adcq	%r13,%rsi
	movq	%rbp,80(%rdi)
	movq	%rsi,88(%rdi)

	.byte	0xf3,0xc3


.type	__blst_redc_tail_mont_384,@function
.align	32
__blst_redc_tail_mont_384:
	.byte	0xf3,0x0f,0x1e,0xfa

	addq	48(%rsi),%r14
	movq	%r14,%rax
	adcq	56(%rsi),%r15
	adcq	64(%rsi),%r8
	adcq	72(%rsi),%r9
	movq	%r15,%rcx
	adcq	80(%rsi),%r10
	adcq	88(%rsi),%r11
	sbbq	%r12,%r12

	movq	%r8,%rdx
	movq	%r9,%rbp

	subq	0(%rbx),%r14
	sbbq	8(%rbx),%r15
	movq	%r10,%r13
	sbbq	16(%rbx),%r8
	sbbq	24(%rbx),%r9
	sbbq	32(%rbx),%r10
	movq	%r11,%rsi
	sbbq	40(%rbx),%r11
	sbbq	$0,%r12

	cmovcq	%rax,%r14
	cmovcq	%rcx,%r15
	cmovcq	%rdx,%r8
	movq	%r14,0(%rdi)
	cmovcq	%rbp,%r9
	movq	%r15,8(%rdi)
	cmovcq	%r13,%r10
	movq	%r8,16(%rdi)
	cmovcq	%rsi,%r11
	movq	%r9,24(%rdi)
	movq	%r10,32(%rdi)
	movq	%r11,40(%rdi)

	.byte	0xf3,0xc3

.type	__blst_redc_tail_mont_384,@function
.align	32
__blst_redc_tail_mont_384:
	.byte	0xf3,0x0f,0x1e,0xfa

	addq	48(%rsi),%r14
	movq	%r14,%rax
	adcq	56(%rsi),%r15
	adcq	64(%rsi),%r8
	adcq	72(%rsi),%r9
	movq	%r15,%rcx
	adcq	80(%rsi),%r10
	adcq	88(%rsi),%r11
	sbbq	%r12,%r12




	movq	%r8,%rdx
	movq	%r9,%rbp

	subq	0(%rbx),%r14
	sbbq	8(%rbx),%r15
	movq	%r10,%r13
	sbbq	16(%rbx),%r8
	sbbq	24(%rbx),%r9
	sbbq	32(%rbx),%r10
	movq	%r11,%rsi
	sbbq	40(%rbx),%r11
	sbbq	$0,%r12

	cmovcq	%rax,%r14
	cmovcq	%rcx,%r15
	cmovcq	%rdx,%r8
	movq	%r14,0(%rdi)
	cmovcq	%rbp,%r9
	movq	%r15,8(%rdi)
	cmovcq	%r13,%r10
	movq	%r8,16(%rdi)
	cmovcq	%rsi,%r11
	movq	%r9,24(%rdi)
	movq	%r10,32(%rdi)
	movq	%r11,40(%rdi)

	.byte	0xf3,0xc3

