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
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    mov rax, 41
    syscall
    mov rbx, rax       
    mov r8, rbx        

    mov rdi, rbx
    lea rsi, [sockaddr_in]
    mov rdx, 16
    mov rax, 49
    syscall

    mov rdi, rbx
    mov rsi, 0
    mov rax, 50
    syscall

Parent_Process:
    mov rdi, r8
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 43
    syscall
    mov rbx, rax     

    mov rax, 57
    syscall
    cmp rax, 0
    je Child_Process

    mov rdi, rbx
    mov rax, 3
    syscall
    jmp Parent_Process

Child_Process:
    mov rdi, r8
    mov rax, 3
    syscall

    sub rsp, 0x10000 
    mov rsi, rsp           
    mov rdi, rbx           
    mov rdx, 0x10000          
    mov rax, 0
    syscall
    mov r12, rax           
    mov r15, rsp           
    mov r10, rsp           

REQUEST_TYPE:
    mov al, [r15]
    cmp al, 'G'
    jne CHECK_POST
    mov al, [r15+1]
    cmp al, 'E'
    jne NEXT_LETTER
    mov al, [r15+2]
    cmp al, 'T'
    jne NEXT_LETTER
    mov al, [r15+3]
    cmp al, ' '
    jne NEXT_LETTER
    jmp HANDLE_GET

NEXT_LETTER:
    inc r15
    jmp REQUEST_TYPE

CHECK_POST:
    mov al, [r15]
    cmp al, 'P'
    jne NEXT_LETTER
    mov al, [r15+1]
    cmp al, 'O'
    jne NEXT_LETTER
    mov al, [r15+2]
    cmp al, 'S'
    jne NEXT_LETTER
    mov al, [r15+3]
    cmp al, 'T'
    jne NEXT_LETTER
    mov al, [r15+4]
    cmp al, ' '
    jne NEXT_LETTER
    jmp HANDLE_POST

FILE_PATH_PARSING:
PARSE:
    mov al, [r10]
    cmp al, ' '
    je Done_Parse
    inc r10
    jmp PARSE

Done_Parse:
    inc r10
    mov r11, r10

Extract:
    mov al, [r11]
    cmp al, ' '
    je Done_Extract
    inc r11
    jmp Extract

Done_Extract:
    mov byte ptr [r11], 0
    ret

HANDLE_GET:
    call FILE_PATH_PARSING
RETURN_POINT:
		lea rdi, [r10]
    mov rsi, 0
    mov rdx, 0
    mov rax, 2
    syscall
    mov r14, rax
    
    mov rdi, r14
    lea rsi, [rsp] 
    mov rdx, 0x10000       
    mov rax, 0
    syscall
    mov r12, rax

    mov rdi, r14
    mov rax, 3
    syscall

    mov rdi, rbx
    lea rsi, [response_message]
    mov rdx, response_end - response_message
    mov rax, 1
    syscall

    mov rdi, rbx
    lea rsi, [rsp] 
    mov rdx, r12
    mov rax, 1
    syscall

    add rsp, 0x10000
    mov rax, 60
    xor rdi, rdi
    syscall

HANDLE_POST:
    call FILE_PATH_PARSING
    
    lea rdi, [r10]
    mov rsi, 65             
    mov rdx, 511           
    mov rax, 2
    syscall
    mov r14, rax
    
    cmp r14, 0
		jl OPEN_FAILED
    
    xor r13, r13 
    xor r9, r9   
    
FIND_HEADER_END:
    cmp r13, r12
    jae NO_CRLF_FOUND

    mov rsi, r12
    sub rsi, r13
    cmp rsi, 4 
    jl NO_CRLF_FOUND

    mov al, [r15 + r13]
    cmp al, 13
    jne INCREMENT_OFFSET
    mov al, [r15 + r13 + 1]
    cmp al, 10
    jne INCREMENT_OFFSET
    mov al, [r15 + r13 + 2]
    cmp al, 13
    jne INCREMENT_OFFSET
    mov al, [r15 + r13 + 3]
    cmp al, 10
    jne INCREMENT_OFFSET

    add r13, 4 
    jmp PARSE_CONTENT_LENGTH_START

INCREMENT_OFFSET:
    inc r13
    jmp FIND_HEADER_END

NO_CRLF_FOUND:
    jmp Close_File_and_Respond

PARSE_CONTENT_LENGTH_START:
    mov rcx, r15     
    mov rdx, r13     
    sub rdx, 4       
    jmp PARSE_HEADERS

PARSE_HEADERS:
    cmp rcx, r15
    add rcx, rdx
    cmp rcx, r15
    jae PARSE_HEADERS_END

    mov rdi, rcx
    add rdi, 15 
    cmp byte ptr [rdi], ':' 
    jne NEXT_HEADER_LINE

    mov al, [rcx]
    cmp al, 'C'
    jne NEXT_HEADER_LINE
    mov al, [rcx+1]
    cmp al, 'o'
    jne NEXT_HEADER_LINE
    mov al, [rcx+2]
    cmp al, 'n'
    jne NEXT_HEADER_LINE
    mov al, [rcx+3]
    cmp al, 't'
    jne NEXT_HEADER_LINE
    mov al, [rcx+4]
    cmp al, 'e'
    jne NEXT_HEADER_LINE
    mov al, [rcx+5]
    cmp al, 'n'
    jne NEXT_HEADER_LINE
    mov al, [rcx+6]
    cmp al, 't'
    jne NEXT_HEADER_LINE
    mov al, [rcx+7]
    cmp al, '-'
    jne NEXT_HEADER_LINE
    mov al, [rcx+8]
    cmp al, 'L'
    jne NEXT_HEADER_LINE
    mov al, [rcx+9]
    cmp al, 'e'
    jne NEXT_HEADER_LINE
    mov al, [rcx+10]
    cmp al, 'n'
    jne NEXT_HEADER_LINE
    mov al, [rcx+11]
    cmp al, 'g'
    jne NEXT_HEADER_LINE
    mov al, [rcx+12]
    cmp al, 't'
    jne NEXT_HEADER_LINE
    mov al, [rcx+13]
    cmp al, 'h'
    jne NEXT_HEADER_LINE
    mov al, [rcx+14]
    cmp al, ':'
    jne NEXT_HEADER_LINE
    mov al, [rcx+15]
    cmp al, ' '
    jne NEXT_HEADER_LINE

    add rcx, 16 
    xor r9, r9 
CONVERT_ASCII_TO_INT:
    movzx eax, byte ptr [rcx]
    cmp al, '0'
    jl CONVERT_DONE
    cmp al, '9'
    jg CONVERT_DONE
    sub al, '0'
    imul r9, 10
    add r9, rax
    inc rcx
    jmp CONVERT_ASCII_TO_INT

CONVERT_DONE:
    jmp PARSE_HEADERS_END

NEXT_HEADER_LINE:
    inc rcx
    mov al, [rcx-1]
    cmp al, 10 
    jne PARSE_HEADERS
    jmp PARSE_HEADERS 

PARSE_HEADERS_END:
    
BODY_FOUND:
    lea rsi, [r15 + r13] 

    mov rdx, r12      
    sub rdx, r13      

    cmp r9, 0         
    je NO_CONTENT_LENGTH_HEADER 

    cmp r9, rdx       
    cmovl rdx, r9     

NO_CONTENT_LENGTH_HEADER:
    mov rdi, r14      
    mov rax, 1        
    syscall

    jmp Close_File_and_Respond

Close_File_and_Respond:
    mov rdi, r14
    mov rax, 3
    syscall

    mov rdi, rbx
    lea rsi, [response_message]
    mov rdx, response_end - response_message
    mov rax, 1
    syscall

    add rsp, 0x10000
    mov rax, 60
    xor rdi, rdi
    syscall

OPEN_FAILED:
    mov rdi, rbx
    lea rsi, [response_message] 
    mov rdx, response_end - response_message
    mov rax, 1
    syscall

    add rsp, 0x10000
    mov rax, 60
    mov rdi, 1 
    syscall
