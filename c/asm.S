
.text
.align  4
# void void_call();
.globl  void_call
void_call:
    ret

.global add
.align 4
add:
    addw	a0,a0,a1
	ret

.global a_ctz
.align 4
a_ctz:
    .byte 0x13, 0x15, 0x15, 0x60
    ret

.global print_hello
print_hello:
    addi sp, sp, -16
    sw ra, 12(sp)
    lui a0, %hi(string1)
    addi a0, a0, %lo(string1)
    lui a1, %hi(string2)
    addi a1, a1, %lo(string2)
    call printf
    lw ra, 12(sp)
    addi sp, sp, 16
    li a0, 0
    ret

    .section .rodata
    .balign 4
string1:
    .string "Hello, %s!\n"
string2:
    .string "world"
