.text
.globl make_fcontext
.type make_fcontext, @function
make_fcontext:
    mov %rdi, %rax
    and $-16, %rax
    sub $8, %rax
    lea fiber_entry_trampoline(%rip), %r10
    mov %r10, (%rax)
    sub $64, %rax
    movq $0, 0(%rax)
    movq $0, 8(%rax)
    mov %rdx, 16(%rax)
    mov %rcx, 24(%rax)
    movq $0, 32(%rax)
    movq $0, 40(%rax)
    movl $0x1f80, 48(%rax)
    movw $0x037f, 52(%rax)
    movq $0, 56(%rax)
    ret
.size make_fcontext, .-make_fcontext

.globl jump_fcontext
.type jump_fcontext, @function
jump_fcontext:
    sub $64, %rsp
    mov %rbp, 0(%rsp)
    mov %rbx, 8(%rsp)
    mov %r12, 16(%rsp)
    mov %r13, 24(%rsp)
    mov %r14, 32(%rsp)
    mov %r15, 40(%rsp)
    stmxcsr 48(%rsp)
    fnstcw 52(%rsp)
    mov %rsp, (%rdi)
    mov %rsi, %rsp
    ldmxcsr 48(%rsp)
    fldcw 52(%rsp)
    mov 0(%rsp), %rbp
    mov 8(%rsp), %rbx
    mov 16(%rsp), %r12
    mov 24(%rsp), %r13
    mov 32(%rsp), %r14
    mov 40(%rsp), %r15
    add $64, %rsp
    ret
.size jump_fcontext, .-jump_fcontext

.type fiber_entry_trampoline, @function
fiber_entry_trampoline:
    mov %r12, %rdi
    mov %r13, %rsi
    call fiber_entry_helper@PLT
    int3
.size fiber_entry_trampoline, .-fiber_entry_trampoline

.section .note.GNU-stack,"",@progbits
