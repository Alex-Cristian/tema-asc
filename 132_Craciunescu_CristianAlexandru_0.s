.section .note.GNU-stack,"",@progbits
.data
    v: .space 4096          
    id: .space 4      
    kB: .space 4
    nrop: .space 4      
    cnt: .long 0
    n: .space 4
    op: .space 4
    pozi: .space 4
    pozf: .space 4
    id_afis: .space 4
    format_int2: .asciz "%d "   
    format_int: .asciz "%d"  
    newline: .asciz "\n"      
    msg_invalid: .asciz "Operatie invalida!\n"
    msg_output: .asciz "(%d, %d)\n"
    msg_output2: .asciz "%d: (%d, %d)\n"
    start: .space 4
    mx: .space 4
    nr: .space 4

.text

etprint: 
    xor %eax, %eax

first_loop:
    cmpl $1024, %eax
    jge end_loop

    movl (%edi, %eax, 4), %ebx
    cmp $0, %ebx
    je next_el
    
    movl %eax, start
    movl %ebx, %edx
    movl %edx, nr

sec:
    incl %eax
    movl (%edi, %eax, 4), %ebx
    cmp %ebx, %edx
    je sec

print:
    decl %eax
    push %eax
    push start
    push nr
    push $msg_output2
    call printf
    pop %ebx
    pop %edx
    pop %ebx
    pop %eax
    jmp next_el

next_el:
    incl %eax
    jmp first_loop

end_loop:
    ret


.global main
main:
    movl $1024, mx
    lea v, %edi

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

    movl op, %eax
    cmpl $1, %eax
    je ADD
    cmpl $2, %eax
    je GET
    cmpl $3, %eax
    je DEL
    cmpl $4, %eax
    je DEF

    jmp for1

ADD:
    pushl $n
    pushl $format_int
    call scanf
    add $8, %esp

for_add:
    movl n, %ecx
    cmpl $0, %ecx
    je add_done
    decl %ecx
    movl %ecx, n

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
    xor %edx, %edx  
    div %ebx

    cmpl $0, %edx
    je skip_add

    inc %eax
    movl %eax, kB
skip_add:

    cmpl $1024, %eax
    je complete
    cmpl mx, %eax
    jge search
    movl %eax, kB
    movl $0, %edx
    movl $0, pozi
    movl id, %esi

    call cauta_poz             
    movl pozi, %eax             
    cmpl $-1, %eax            
    je eroare                  

    movl kB, %eax               
    movl pozi, %edx             

et_add:
    cmpl $0, %eax
    je add_afis
    movl %esi, (%edi, %edx, 4)
    decl %eax
    movl %edx, pozf
    incl %edx
    jmp et_add

complete:
    movl $0, pozi
    movl $1023, pozf
    cmpl $1024, mx
    jl eroare
    movl $0, %edx
    movl (%edi, %edx, 4), %esi
    cmpl $0, %esi
    jne eroare
    movl $1024, %eax
    movl id, %esi

add_complete:
    cmpl $0, %eax
    je add_afis
    movl %esi, (%edi, %edx, 4)
    decl %eax
    incl %edx
    jmp add_complete

add_afis:
    pushl pozf
    pushl pozi
    pushl id
    pushl $msg_output2
    call printf
    add $16, %esp
    movl $1024, %eax
    subl pozf, %eax
    movl %eax, mx
    jmp for_add

add_done:
    movl $1023, mx
    jmp for1

cauta_poz:
    movl $0, %ebx             
    movl $0, cnt                
    movl $-1, pozi           

iterate:
    cmp $1024, %ebx              
    je eroare                

    movl (%edi, %ebx, 4), %edx 
    cmp $0, %edx                
    jne reset_counter         

    cmpl $-1, pozi              
    jne continue_search        

    movl %ebx, pozi             

continue_search:
    incl cnt 
    movl cnt, %eax                 
    cmpl kB, %eax              
    je found_space              

    incl %ebx                   
    jmp iterate              

reset_counter:
    movl $0, cnt                
    movl $-1, pozi           
    incl %ebx               
    jmp iterate                 

found_space:
    ret   

eroare:            
    movl $0, pozi
    movl $0, pozf
    pushl pozf
    pushl pozi
    pushl id
    pushl $msg_output2
    call printf
    add $16, %esp
    jmp for_add

search:
    movl $0, %ebx

search_0:
    cmpl $1024, %ebx
    je eroare
    movl (%edi, %ebx, 4), %ecx
    cmpl $0, %ecx
    je found

    incl %ebx
    jmp search_0

found:
    movl $1024, mx
    movl %eax, kB
    movl $0, %edx
    movl $0, pozi
    movl id, %esi

    call cauta_poz             
    movl pozi, %eax             
    cmpl $-1, %eax            
    je eroare                  

    movl kB, %eax               
    movl pozi, %edx             

et_add_f:
    cmpl $0, %eax
    je add_afis
    movl %esi, (%edi, %edx, 4)
    decl %eax
    movl %edx, pozf
    incl %edx
    jmp et_add_f

GET:
    pushl $id
    pushl $format_int
    call scanf
    add $8, %esp

    movl $0, %ebx               
    movl $-1, pozi              
    movl $-1, pozf              
    movl id, %esi               

get_loop:
    cmp $1024, %ebx             
    je get_done             

    movl (%edi, %ebx, 4), %eax  
    cmpl %esi, %eax           
    jne get_continue            

    cmpl $-1, pozi              
    je set_pozi                 

    movl %ebx, pozf             
    jmp get_continue

set_pozi:
    movl %ebx, pozi            
    movl %ebx, pozf            

get_continue:
    incl %ebx                  
    jmp get_loop                

get_done:
    cmpl $-1, pozi              
    je eroare_get                

    pushl pozf                 
    pushl pozi                 
    pushl $msg_output          
    call printf                 
    add $12, %esp   

    jmp for1                  

eroare_get:
    movl $0, pozi
    movl $0, pozf
    pushl pozf
    pushl pozi
    pushl $msg_output
    call printf
    add $12, %esp
    jmp for1

DEL:
    pushl $id
    pushl $format_int
    call scanf
    add $8, %esp

    movl $0, %eax

for_del:
    cmpl $1024, %eax
    je del_done
    movl (%edi, %eax, 4), %edx
    cmp id, %edx
    je del_found
    
    incl %eax
    jmp for_del

del_found:
    movl $1024, mx
    movl $0, (%edi, %eax, 4)
    incl %eax
    movl (%edi, %eax, 4), %ebx
    jmp for_del

del_done: 
    call etprint
    jmp for1
DEF:
    movl $0, %eax
    movl $0, %ebx

for_def:
    cmpl $1024, %eax
    je def_done
    movl (%edi, %eax, 4), %edx
    cmpl $0, %edx
    jne def_found
    incl %eax
    jmp for_def

def_found:
    movl %edx, (%edi, %ebx, 4)
    cmpl %ebx, %eax
    jne reset     
    incl %eax
    incl %ebx
    jmp for_def

reset:
    movl $0, (%edi, %eax, 4)
    incl %eax
    incl %ebx
    jmp for_def

def_done:
    call etprint
    jmp for1

etexit:       

    pushl $0
    call fflush
    add $4, %esp

    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
