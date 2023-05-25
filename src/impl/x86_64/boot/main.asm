global start

section .text
bits 32
start:
	mov esp, stack_top

	call check_multiboot ; Checking if the OS is loaded with an multiboot bootloader
	call check_cpuid ; Checking the CPU ID
	call check_long_mode ; Checking if the CPU supports long mode

	call setup_page_tables
	call enable_paging

	;print OK
	mov dword [0xb8000], 0x2f4b2f4f
	hlt


check_cpuid:
	pushfd
	pop eax
	mov ecx, eax
	xor eax, 1 << 21
	push eax
	popfd
	pushfd
	pop eax
	push ecx
	popfd
	cmp eax, ecx
	je .no_cpuid
.no_cpuid:
	mov al, "C"
	jmp error

check_multiboot:
	cmp eax, 0x36d76289
	jne .no_multiboot
	ret
.no_multiboot:
	mov al, "M"

	jmp error

error:
	;print "ERR: X" where X is the error code
	mov dword [0xb8000], 0x4f524f45
	mov dword [0xb8004], 0x4f3a4f52
	mov dword [0xb8008], 0x4f204f20
	mov dword [0xb800a], al
	hlt ; Haltin' the CPU

check_long_mode:
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .no_long_mode

	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .no_long_mode

	ret
.no_long_mode:
	mov al, "L"
	jmp error

section .bss
align 4096
page_table_l4:
	resb 4096
page_table_l3:
	resb 4096
page_table_l3:
	resb 4096

stack_bottom:
	resb 4096 * 4 ; Reserves Memory for stack
stack_top: