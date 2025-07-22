.global main

.section .data

hex_format: .asciz "%#x"
float_format: .asciz "%.2f"
long_float_format: .asciz "%.2Lf"

.section .text

.macro trap
        /* kill with SIGTRAP */
        movq $62, %rax
        movq %r12, %rdi
        movq $5, %rsi
        syscall
.endm

main:

	/* Prologue */
	// Callee saved - rbp originally contains the caller's stack frame addr
	push %rbp
	// new stack frame
	movq %rsp, %rbp


	/* get PID */
	movq $39, %rax
	syscall
	movq %rax, %r12
	
	trap

	leaq hex_format(%rip), %rdi
	movq $0, %rax
	call printf@plt
	movq $0, %rdi	
	call fflush@plt

	trap

	// Print contents of mm0
	movq %mm0, %rsi
	leaq hex_format(%rip), %rdi
	movq $0, %rax
	call printf@plt
	movq $0, %rdi
	call fflush@plt
	trap

	// Print contents of xmm0
	leaq float_format(%rip), %rdi
	movq $1, %rax
	call printf@plt
	movq $0, %rdi
	call fflush@plt
	trap

	// Print contents of st0
	subq $16, %rsp
	fstpt (%rsp)
	leaq long_float_format(%rip), %rdi
	movq $0, %rax
	call printf@plt
	movq $0, %rdi
	call fflush@plt
	addq $16, %rsp
	trap

	/* Epilogue */
	// restore rbp
	popq %rbp
	// return 0
	movq $0, %rax
	ret
