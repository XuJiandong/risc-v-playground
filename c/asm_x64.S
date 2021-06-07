.globl    _test_adc
.align   4
_test_adc:
	pushq	%rbp
	movq	%rsp, %rbp

	movq   $-1, %r10
    movq   $1, %r11
    addq   %r10, %r11
    # CF = 1 now
    # DEST ← (DEST + (SRC + CF));
    # make (SRC+CF) to carry
    movq   $-1, %r12 # SRC
    movq   $0, %r13 # DEST
    adcq   %r12, %r13

    # CF should be 1
    pushfq
    popq %rax

	popq %rbp
    retq

.globl    _test_sbb
.align   4
_test_sbb:
	pushq	%rbp
	movq	%rsp, %rbp

	movq   $2, %r10
    movq   $1, %r11
    subq   %r10, %r11
    # CF = 1 now
    # DEST ← (DEST – (SRC + CF));
    # make (SRC+CF) to carry
    movq   $-1, %r12 # SRC
    movq   $-1, %r13 # DEST
    sbbq   %r12, %r13

    pushfq
    popq %rax

	popq %rbp
    retq


.globl    _test_add
.align   4
_test_add:
	pushq	%rbp
	movq	%rsp, %rbp

	movq   $-1, %r10
    movq   $1, %r11
    addq   %r10, %r11

    pushfq
    popq %rax

	popq %rbp
    retq

