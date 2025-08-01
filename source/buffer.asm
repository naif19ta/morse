# Morse - encoder and decoder
# 23 Jun 2025
# This file handles buffering

.section .bss
        .buffer: .zero 2048

.section .data
        .offset: .quad 0

.section .text

# This function is called whenever the program needs to flush
# something
# rdi = thing to flush
# rsi = if equals rsi > 0 wirte only first rsi bytes, write whole rdi's content otherwise
.globl BufWri
BufWri:
	movq	(.offset), %r14
	leaq	.buffer(%rip), %r13
	addq	%r14, %r13
	cmpq	$1, %rsi
	jne	.bw_loop
	cmpq	$2048, %r14
	jl	.bf_1
	pushq	%rdi
	call	BufPuts
	popq	%rdi
	movq	$0, %r14
	leaq	.buffer(%rip), %r13
.bf_1:
	movzbl	(%rdi), %eax
	movb	%al, (%r13)
	incq	%r14
	movq	%r14, (.offset)
	ret
.bw_loop:
	cmpq	$2048, %r14
	je	.bw_full
	movzbl	(%rdi), %r15d
	cmpb	$0, %r15b
	je	.bw_return
	movb	%r15b, (%r13)
	incq	%r14
	incq	%r13
	incq	%rdi
	jmp	.bw_loop
.bw_return:
	movq	%r14, (.offset)
	ret
.bw_full:
	pushq	%rsi
	pushq	%rdi
	movq	$4, (.offset)
	call 	BufPuts
	popq	%rdi
	popq	%rsi
	movq	(.offset), %r14
	leaq	.buffer(%rip), %r13
	jmp	.bw_loop


.globl BufPuts
BufPuts:
	leaq	.buffer(%rip), %rsi
	movq	(.offset), %rdx
	movq	$1, %rax
	movq	$1, %rdi
	syscall
	movq	$0, (.offset)
	ret
