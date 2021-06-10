.globl    blst_mul_mont_384
.type    blst_mul_mont_384,@function
.align    32
blst_mul_mont_384:
    .byte    0xf3,0x0f,0x1e,0xfa
    pushq    %rbp
    pushq    %rbx
    pushq    %r12
    pushq    %r13
    pushq    %r14
    pushq    %r15
    subq    $24,%rsp

    movq    0(%rdx),%rax
    movq    0(%rsi),%r14
    movq    8(%rsi),%r15
    movq    16(%rsi),%r12
    movq    24(%rsi),%r13
    movq    %rdx,%rbx
    movq    %r8,0(%rsp)
    movq    %rdi,8(%rsp)

    call    __blst_mulq_mont_384

    movq    24(%rsp),%r15
    movq    32(%rsp),%r14
    movq    40(%rsp),%r13
    movq    48(%rsp),%r12
    movq    56(%rsp),%rbx
    movq    64(%rsp),%rbp
    leaq    72(%rsp),%rsp
    .byte    0xf3,0xc3


.type    __blst_mulq_mont_384,@function
.align    32
__blst_mulq_mont_384:
    .byte    0xf3,0x0f,0x1e,0xfa
    movq    %rax,%rdi
    mulq    %r14
    movq    %rax,%r8
    movq    %rdi,%rax
    movq    %rdx,%r9

    mulq    %r15
    addq    %rax,%r9
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r10

    mulq    %r12
    addq    %rax,%r10
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r11

    movq    %r8,%rbp
    imulq    8(%rsp),%r8

    mulq    %r13
    addq    %rax,%r11
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r12

    mulq    32(%rsi)
    addq    %rax,%r12
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r13

    mulq    40(%rsi)
    addq    %rax,%r13
    movq    %r8,%rax
    adcq    $0,%rdx
    xorq    %r15,%r15
    movq    %rdx,%r14

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r8,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r9
    movq    %r8,%rax
    adcq    $0,%rdx
    addq    %rbp,%r9
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r10
    movq    %r8,%rax
    adcq    $0,%rdx
    addq    %rbp,%r10
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r11
    adcq    $0,%rdx
    addq    %rax,%r11
    movq    %r8,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r12
    movq    %r8,%rax
    adcq    $0,%rdx
    addq    %rbp,%r12
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r13
    movq    8(%rbx),%rax
    adcq    $0,%rdx
    addq    %rbp,%r13
    adcq    %rdx,%r14
    adcq    $0,%r15

    movq    %rax,%rdi
    mulq    0(%rsi)
    addq    %rax,%r9
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r8

    mulq    8(%rsi)
    addq    %rax,%r10
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r8,%r10
    adcq    $0,%rdx
    movq    %rdx,%r8

    mulq    16(%rsi)
    addq    %rax,%r11
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r8,%r11
    adcq    $0,%rdx
    movq    %rdx,%r8

    movq    %r9,%rbp
    imulq    8(%rsp),%r9

    mulq    24(%rsi)
    addq    %rax,%r12
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r8,%r12
    adcq    $0,%rdx
    movq    %rdx,%r8

    mulq    32(%rsi)
    addq    %rax,%r13
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r8,%r13
    adcq    $0,%rdx
    movq    %rdx,%r8

    mulq    40(%rsi)
    addq    %r8,%r14
    adcq    $0,%rdx
    xorq    %r8,%r8
    addq    %rax,%r14
    movq    %r9,%rax
    adcq    %rdx,%r15
    adcq    $0,%r8

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r9,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r10
    movq    %r9,%rax
    adcq    $0,%rdx
    addq    %rbp,%r10
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r11
    movq    %r9,%rax
    adcq    $0,%rdx
    addq    %rbp,%r11
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r12
    adcq    $0,%rdx
    addq    %rax,%r12
    movq    %r9,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r13
    movq    %r9,%rax
    adcq    $0,%rdx
    addq    %rbp,%r13
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r14
    movq    16(%rbx),%rax
    adcq    $0,%rdx
    addq    %rbp,%r14
    adcq    %rdx,%r15
    adcq    $0,%r8

    movq    %rax,%rdi
    mulq    0(%rsi)
    addq    %rax,%r10
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r9

    mulq    8(%rsi)
    addq    %rax,%r11
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r9,%r11
    adcq    $0,%rdx
    movq    %rdx,%r9

    mulq    16(%rsi)
    addq    %rax,%r12
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r9,%r12
    adcq    $0,%rdx
    movq    %rdx,%r9

    movq    %r10,%rbp
    imulq    8(%rsp),%r10

    mulq    24(%rsi)
    addq    %rax,%r13
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r9,%r13
    adcq    $0,%rdx
    movq    %rdx,%r9

    mulq    32(%rsi)
    addq    %rax,%r14
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r9,%r14
    adcq    $0,%rdx
    movq    %rdx,%r9

    mulq    40(%rsi)
    addq    %r9,%r15
    adcq    $0,%rdx
    xorq    %r9,%r9
    addq    %rax,%r15
    movq    %r10,%rax
    adcq    %rdx,%r8
    adcq    $0,%r9

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r10,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r11
    movq    %r10,%rax
    adcq    $0,%rdx
    addq    %rbp,%r11
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r12
    movq    %r10,%rax
    adcq    $0,%rdx
    addq    %rbp,%r12
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r13
    adcq    $0,%rdx
    addq    %rax,%r13
    movq    %r10,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r14
    movq    %r10,%rax
    adcq    $0,%rdx
    addq    %rbp,%r14
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r15
    movq    24(%rbx),%rax
    adcq    $0,%rdx
    addq    %rbp,%r15
    adcq    %rdx,%r8
    adcq    $0,%r9

    movq    %rax,%rdi
    mulq    0(%rsi)
    addq    %rax,%r11
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r10

    mulq    8(%rsi)
    addq    %rax,%r12
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r10,%r12
    adcq    $0,%rdx
    movq    %rdx,%r10

    mulq    16(%rsi)
    addq    %rax,%r13
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r10,%r13
    adcq    $0,%rdx
    movq    %rdx,%r10

    movq    %r11,%rbp
    imulq    8(%rsp),%r11

    mulq    24(%rsi)
    addq    %rax,%r14
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r10,%r14
    adcq    $0,%rdx
    movq    %rdx,%r10

    mulq    32(%rsi)
    addq    %rax,%r15
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r10,%r15
    adcq    $0,%rdx
    movq    %rdx,%r10

    mulq    40(%rsi)
    addq    %r10,%r8
    adcq    $0,%rdx
    xorq    %r10,%r10
    addq    %rax,%r8
    movq    %r11,%rax
    adcq    %rdx,%r9
    adcq    $0,%r10

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r11,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r12
    movq    %r11,%rax
    adcq    $0,%rdx
    addq    %rbp,%r12
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r13
    movq    %r11,%rax
    adcq    $0,%rdx
    addq    %rbp,%r13
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r14
    adcq    $0,%rdx
    addq    %rax,%r14
    movq    %r11,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r15
    movq    %r11,%rax
    adcq    $0,%rdx
    addq    %rbp,%r15
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r8
    movq    32(%rbx),%rax
    adcq    $0,%rdx
    addq    %rbp,%r8
    adcq    %rdx,%r9
    adcq    $0,%r10

    movq    %rax,%rdi
    mulq    0(%rsi)
    addq    %rax,%r12
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r11

    mulq    8(%rsi)
    addq    %rax,%r13
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r11,%r13
    adcq    $0,%rdx
    movq    %rdx,%r11

    mulq    16(%rsi)
    addq    %rax,%r14
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r11,%r14
    adcq    $0,%rdx
    movq    %rdx,%r11

    movq    %r12,%rbp
    imulq    8(%rsp),%r12

    mulq    24(%rsi)
    addq    %rax,%r15
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r11,%r15
    adcq    $0,%rdx
    movq    %rdx,%r11

    mulq    32(%rsi)
    addq    %rax,%r8
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r11,%r8
    adcq    $0,%rdx
    movq    %rdx,%r11

    mulq    40(%rsi)
    addq    %r11,%r9
    adcq    $0,%rdx
    xorq    %r11,%r11
    addq    %rax,%r9
    movq    %r12,%rax
    adcq    %rdx,%r10
    adcq    $0,%r11

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r12,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r13
    movq    %r12,%rax
    adcq    $0,%rdx
    addq    %rbp,%r13
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r14
    movq    %r12,%rax
    adcq    $0,%rdx
    addq    %rbp,%r14
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r15
    adcq    $0,%rdx
    addq    %rax,%r15
    movq    %r12,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r8
    movq    %r12,%rax
    adcq    $0,%rdx
    addq    %rbp,%r8
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r9
    movq    40(%rbx),%rax
    adcq    $0,%rdx
    addq    %rbp,%r9
    adcq    %rdx,%r10
    adcq    $0,%r11

    movq    %rax,%rdi
    mulq    0(%rsi)
    addq    %rax,%r13
    movq    %rdi,%rax
    adcq    $0,%rdx
    movq    %rdx,%r12

    mulq    8(%rsi)
    addq    %rax,%r14
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r12,%r14
    adcq    $0,%rdx
    movq    %rdx,%r12

    mulq    16(%rsi)
    addq    %rax,%r15
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r12,%r15
    adcq    $0,%rdx
    movq    %rdx,%r12

    movq    %r13,%rbp
    imulq    8(%rsp),%r13

    mulq    24(%rsi)
    addq    %rax,%r8
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r12,%r8
    adcq    $0,%rdx
    movq    %rdx,%r12

    mulq    32(%rsi)
    addq    %rax,%r9
    movq    %rdi,%rax
    adcq    $0,%rdx
    addq    %r12,%r9
    adcq    $0,%rdx
    movq    %rdx,%r12

    mulq    40(%rsi)
    addq    %r12,%r10
    adcq    $0,%rdx
    xorq    %r12,%r12
    addq    %rax,%r10
    movq    %r13,%rax
    adcq    %rdx,%r11
    adcq    $0,%r12

    mulq    0(%rcx)
    addq    %rax,%rbp
    movq    %r13,%rax
    adcq    %rdx,%rbp

    mulq    8(%rcx)
    addq    %rax,%r14
    movq    %r13,%rax
    adcq    $0,%rdx
    addq    %rbp,%r14
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    16(%rcx)
    addq    %rax,%r15
    movq    %r13,%rax
    adcq    $0,%rdx
    addq    %rbp,%r15
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    24(%rcx)
    addq    %rbp,%r8
    adcq    $0,%rdx
    addq    %rax,%r8
    movq    %r13,%rax
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    32(%rcx)
    addq    %rax,%r9
    movq    %r13,%rax
    adcq    $0,%rdx
    addq    %rbp,%r9
    adcq    $0,%rdx
    movq    %rdx,%rbp

    mulq    40(%rcx)
    addq    %rax,%r10
    movq    %r14,%rax
    adcq    $0,%rdx
    addq    %rbp,%r10
    adcq    %rdx,%r11
    adcq    $0,%r12

    movq    16(%rsp),%rdi
    subq    0(%rcx),%r14
    movq    %r15,%rdx
    sbbq    8(%rcx),%r15
    movq    %r8,%rbx
    sbbq    16(%rcx),%r8
    movq    %r9,%rsi
    sbbq    24(%rcx),%r9
    movq    %r10,%rbp
    sbbq    32(%rcx),%r10
    movq    %r11,%r13
    sbbq    40(%rcx),%r11
    sbbq    $0,%r12

    cmovcq    %rax,%r14
    cmovcq    %rdx,%r15
    cmovcq    %rbx,%r8
    movq    %r14,0(%rdi)
    cmovcq    %rsi,%r9
    movq    %r15,8(%rdi)
    cmovcq    %rbp,%r10
    movq    %r8,16(%rdi)
    cmovcq    %r13,%r11
    movq    %r9,24(%rdi)
    movq    %r10,32(%rdi)
    movq    %r11,40(%rdi)

    .byte    0xf3,0xc3
