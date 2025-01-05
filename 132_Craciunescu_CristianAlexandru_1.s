.section .note.GNU-stack,"",@progbits
.data
    a: .space 4194304
    i: .space 4
    j: .space 4
    size: .long 0            
    id: .space 4      
    kB: .space 4
    nrop: .space 4      
    cnt: .long 0
    n: .space 4
    m: .space 4
    op: .space 4
    pozitie1: .space 4
    pozitie2: .space 4
    pozi: .space 4
    pozf: .space 4
    format_int: .asciz "%d"   
    newline: .asciz "\n"      
    msg_invalid: .asciz "Operatie invalida!\n"
    msg_output: .asciz "%d: (%d, %d)\n"
    rows:           .space 4            
    cols:           .space 4        
    format_output:  .asciz "%d: ((%d, %d), (%d, %d))\n"
    last_j: .space 4
    found_row: .space 4
    found_col: .space 4

.text
.global main

main:
    lea a, %edi
    pushl $nrop
    pushl $format_int
    call scanf
    add $8, %esp

for1:
    movl nrop, %ecx
    cmpl $0, %ecx
    je etexit
    decl %ecx
    movl %ecx, nrop

    pushl $op
    pushl $format_int
    call scanf 
    add $8, %esp

    cmpl $1, op
    je ADD
    cmpl $2, op
    je GET
    cmpl $3, op
    je DEL
    cmpl $4, op
    je DEF
    cmpl $5, op
    je CONCRETE

ADD:
    pushl $n
    pushl $format_int
    call scanf
    add $8, %esp

for_add:
    movl n, %eax
    cmpl $0, %eax
    je add_done
    decl %eax
    movl %eax, n

    pushl $id 
    pushl $format_int
    call scanf
    add $8, %esp

    pushl $kB
    pushl $format_int
    call scanf
    add $8, %esp

    cmpl $8, kB
    jle for_add

    movl kB, %eax
    movl $8, %ebx
    xorl %edx, %edx
    divl %ebx

    cmpl $0, %edx
    je etinc

    incl %eax
    movl %eax, kB


etinc:
    movl %eax, kB
    movl $0, i
    movl $0, j
    xorl %ecx, %ecx


start:
    movl $0, i                     
    movl $0, j                    

fori:
    cmpl $1024, i                  
    jge not_found
    movl $0, cnt                  

forj:
    cmpl $1024, j                  
    je incl_i

    movl i, %eax                  
    imull $1024, %eax               
    addl j, %eax                  
    lea (%edi, %eax, 4), %ebx     

    movl (%ebx), %ecx            
    cmpl $0, %ecx                 
    jne reset_cnt                 

    incl cnt                     
    movl cnt, %edx
    cmpl kB, %edx                
    je found_space

    incl j                       
    jmp forj

reset_cnt:
    movl $0, cnt                 
    incl j                       
    jmp forj

incl_i:
    incl i                       
    movl $0, j                  
    jmp fori

found_space:
    movl i, %eax
    movl %eax, found_row        
    movl j, %eax
    movl %eax, last_j            
    subl cnt, %eax
    incl %eax                   
    movl %eax, found_col

    call fill_free_space

not_found:
    pushl $0
    pushl $0
    pushl $0
    pushl $0
    pushl id
    pushl $format_output
    call printf
    addl $24, %esp
    jmp for_add

fill_free_space:
    movl found_row, %eax          
    movl %eax, i                  
    movl found_col, %eax        
    movl %eax, j                 

fill_loop:
    movl i, %eax
    imull $1024, %eax               
    addl j, %eax                  
    lea (%edi, %eax, 4), %ebx    

    movl id, %esi
    movl %esi, (%ebx)

    incl j
    movl last_j, %esi
    cmpl %esi, j                
    jg fill_done
    jmp fill_loop

fill_done:
    pushl last_j
    pushl found_row
    pushl found_col
    pushl found_row
    pushl id
    pushl $format_output
    call printf
    addl $24, %esp 
    jmp for_add  

add_done:
    jmp for1

GET:
DEL:
DEF:
CONCRETE:

etexit:       
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
