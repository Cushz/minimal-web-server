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

	#Socket
	mov rdi, 2
	mov rsi, 1
	mov rdx, 0
	mov rax, 41  
	syscall
	
	mov rbx, rax 
	
	#Bind
	mov rdi, rbx
	lea rsi, [sockaddr_in]
	mov rdx, 16
	mov rax, 49
	syscall

	#Listen
	mov rsi, 0
	mov rax, 50
	syscall	

	#Accept
	mov rsi, 0
	mov rdx, 0
	mov rax, 43
	syscall	
	mov rbx, rax

	#Fork
	mov rax, 57
	syscall
	
	cmp rax, 0
	je Child_Process
	
	Parent_Process:
			#Close
			mov rdi, 4
			mov rax, 3
			syscall
			
			#Accept
			mov rdi, 3
			mov rsi, 0
			mov rdx, 0
			mov rax, 43
			syscall	
	
	Child_Process:
			#Close
			mov rdi, 3
			mov rax, 3
			syscall
	
			#Read
			mov rdi, rbx
			sub rsp, 255
			mov rsi, rsp
			mov rdx, 255
			mov rax, 0
			syscall 
		
			mov r10, rsp
		
			PARSE:
				mov al, [r10]
				cmp al, ' '
				je Done
				
				add r10, 1
				jmp PARSE
			
			Done:
				add r10, 1
				mov r11, r10
		
			Extract:
				mov al, [r11]
				cmp al, ' '
				je Done_2
				
				add r11, 1
				jmp Extract
		
			Done_2:
				mov byte ptr [r11], 0
			
			#Open
			lea rdi, [r10]
			mov rsi, 0
			mov rax, 2
			syscall 	
			
			mov rcx, rax
			
			#Read
			mov rdi, rcx
			lea rsi, [rsp+162]
			mov rdx, 255
			mov rax, 0
			syscall
		
			mov r12, rax	
			
			#Close
			mov rdi, 3
			mov rax, 3
			syscall
		
			#Write
			mov rdi, rbx
			lea rsi, [response_message]
			mov rdx, response_end-response_message
			mov rax, 1
			syscall
		
			#Write
			mov rdi, 4
			lea rsi, [rsp+162]
			mov rdx, r12
			mov rax, 1
			syscall 
		
			#Exit
			mov rax, 60
			xor rdi, rdi
			syscall