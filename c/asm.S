
.text
# void void_call();
.globl  void_call
.align  4
void_call:
    ret

.global add
.align 4
add:
    addw	a0,a0,a1
	ret
