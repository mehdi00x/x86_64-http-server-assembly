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
mov rdx, 256
mov rax, 0
syscall


# Parse GET request - find first space
mov rcx, 0
find_space:
	cmp BYTE PTR [http_request + rcx], ' '
	je start_copy
	inc rcx
	jmp find_space


start_copy:
	inc rcx
	xor r10, r10
	
copy_loop:
	mov al, [http_request + rcx]
	cmp al, ' '
	je finish_copy
	lea r11, [rip + path_file]
	add r11, r10
	mov [r11], al
	inc r10
	inc rcx
	jmp copy_loop

finish_copy:
	lea r11, [rip + path_file]
	add r11, r10
	mov BYTE PTR [r11], 0 

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

# Send HTTP response header
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
	.word 0x5000
	.long 0
	.quad 0
	
http_response: .ascii "HTTP/1.0 200 OK\r\n\r\n"

.section .bss
http_request: .skip 256
path_file: .skip 256
flag: .skip 256