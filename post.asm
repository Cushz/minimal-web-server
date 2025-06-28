.section .data
sockaddr_in:
    .word 2
    .word 0x5000
    .long 0
    .quad 0

response_message:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"
response_end:

.global _start
.section .text

_start:
    # Socket
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    mov rax, 41
    syscall
    mov rbx, rax     # socket FD

    # Bind
    mov rdi, rbx
    lea rsi, [sockaddr_in]
    mov rdx, 16
    mov rax, 49
    syscall

    # Listen
    mov rdi, rbx
    mov rsi, 0
    mov rax, 50
    syscall

    # Accept
    mov rdi, rbx
    mov rsi, 0
    mov rdx, 0
    mov rax, 43
    syscall
    mov rbx, rax     # client FD

    # Fork
    mov rax, 57
    syscall
    cmp rax, 0
    je Child_Process

Parent_Process:
    # Close client socket in parent
    mov rdi, rbx
    mov rax, 3
    syscall

    # Accept again
    mov rdi, 3
    mov rsi, 0
    mov rdx, 0
    mov rax, 43
    syscall
    mov rbx, rax

    # Fork again
    mov rax, 57
    syscall
    cmp rax, 0
    je Child_Process
    jmp Parent_Process

Child_Process:
    # Close listening socket in child
    mov rdi, 3
    mov rax, 3
    syscall

    # Read into stack buffer
    sub rsp, 500
    mov rsi, rsp
    mov rdi, rbx
    mov rdx, 500
    mov rax, 0
    syscall
    mov r12, rax        
    mov r15, rsp        
    mov r10, rsp       

PARSE:
    mov al, [r10]
    cmp al, ' '
    je Done_Parse
    add r10, 1
    jmp PARSE

Done_Parse:
    add r10, 1
    mov r11, r10

Extract:
    mov al, [r11]
    cmp al, ' '
    je Done_Extract
    add r11, 1
    jmp Extract

Done_Extract:
    mov byte ptr [r11], 0

    # Open file for writing
    lea rdi, [r10]       
    mov rsi, 1
    or  rsi, 64           
    mov rdx, 511          
    mov rax, 2
    syscall
    mov r14, rax          

    # Find \r\n\r\n
    lea rsi, [rsp]        
FINDCRLF:
    mov al, [rsi]
    cmp al, 13            
    jne NEXT
    mov al, [rsi+1]
    cmp al, 10            
    jne NEXT
    mov al, [rsi+2]
    cmp al, 13            
    jne NEXT
    mov al, [rsi+3]
    cmp al, 10            
    jne NEXT
    add rsi, 4            
    jmp FOUND

NEXT:
    inc rsi
    jmp FINDCRLF

FOUND:
    lea rdx, [r15 + r12]  
    sub rdx, rsi         
    mov r13, rdx         

    # Write body to file
    mov rdi, r14          
    mov rax, 1            
    syscall

    # Close file
    mov rdi, r14
    mov rax, 3
    syscall

    # Send HTTP response
    mov rdi, rbx          # client FD
    lea rsi, [response_message]
    mov rdx, response_end - response_message
    mov rax, 1
    syscall

    # Exit
    mov rax, 60
    xor rdi, rdi
    syscall
