.intel_syntax noprefix
.globl _start

.section .text

_start:

# Socket creation
mov rdi, 2
mov rsi, 1
mov rdx, 0
mov rax, 41
syscall
mov r8, rax

# Bind
mov rdi, r8
lea rsi, [rip + sockaddr_in]
mov rdx, 16
mov rax, 49
syscall

# Listen
mov rdi, r8
mov rsi, 0
mov rax, 50
syscall

accept_loop:

# Accept
mov rdi, r8
mov rsi,0
mov rdx,0
mov rax, 43
syscall
mov r9, rax

#fork()
mov rax, 57
syscall

cmp rax, 0
je child_process

mov rdi, r9
mov rax, 3
syscall

jmp accept_loop

child_process:

# Close the listening socket
mov rdi, r8
mov rax, 3
syscall

# Read HTTP request
mov rdi, r9
lea rsi, [rip + http_request]
mov rdx, 4096
mov rax, 0
syscall
mov r14, rax



# Parse POST request - find first space
xor rcx, rcx
find_space_loop:
	cmp BYTE PTR [http_request + rcx], ' '
	je start_copy
	inc rcx
	jmp find_space_loop


start_copy:
	inc rcx
	inc rcx
	xor r10, r10
	lea r11, [rip + path_file]
copy_loop:
	mov al, BYTE PTR [http_request + rcx]
	cmp al, ' '
	je finish_copy
	mov BYTE PTR [r11 + r10], al
	inc r10
	inc rcx
	jmp copy_loop

finish_copy:
	mov BYTE PTR [r11 + r10], 0

#determine the request_type
mov al, 'G'
cmp BYTE PTR BYTE PTR [http_request], al
je GET_request
	
#Find headers_end
xor rcx, rcx
find_headers_end:
	cmp DWORD PTR [http_request + rcx], 0x0A0D0A0D
	je found_headers_end
	inc rcx
	jmp find_headers_end

found_headers_end:
	add rcx, 4
	mov r13, r14
	sub r13, rcx	#r13_is_the_body_length
	mov rbx, r13

xor r10, r10
lea r11, [rip + flag]
copy_body:
	mov al, BYTE PTR [http_request + rcx]
	mov BYTE PTR [r11 + r10], al
	inc r10
	dec r13
	inc rcx
	cmp r13, 0
	jne copy_body

# Open file
lea rdi, [rip + path_file]
mov rsi, 65 	# O_WRONLY|O_CREAT
mov rdx, 0777
mov rax, 2
syscall
mov r8, rax

# Write the body to the file content
mov rdi, r8
lea rsi, [rip + flag]
mov rdx, rbx
mov rax, 1
syscall

# Close file
mov rdi, r8
mov rax, 3
syscall


mov rdi, r9
lea rsi, [rip + http_response]
mov rdx, 19
mov rax, 1
syscall
jmp fin


GET_request:
	
	# Open file
	lea rdi, [rip + path_file]
	mov rsi, 0
	mov rdx, 0
	mov rax, 2
	syscall
	mov r10, rax

	# Read file contents
	mov rdi, r10
	lea rsi, [rip + flag]
	mov rdx, 256
	mov rax, 0
	syscall
	mov r12, rax

	# Close file
	mov rdi, r10
	mov rax, 3
	syscall
	
	
	mov rdi, r9
	lea rsi, [rip + http_response]
	mov rdx, 19
	mov rax, 1
	syscall
	
	# Send file contents
	mov rdi, r9
	lea rsi, [rip + flag]	
	mov rdx, r12
	mov rax, 1
	syscall


	
fin:
	# Close client socket
	mov rdi, r9
	mov rax, 3
	syscall

	# Exit
	mov rdi, 0
	mov rax, 60
	syscall	



.section .data

sockaddr_in:
	.word 2
	.word 0x901F
	.long 0
	.quad 0
	
http_response: .ascii "HTTP/1.0 200 OK\r\n\r\n"

.section .bss
http_request: .skip 4096
path_file: .skip 256
flag: .skip 256