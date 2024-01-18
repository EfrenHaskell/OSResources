.extern kernel_main // extern indic. external 
			  // refers to the main function in kernel.c file

.global start // start is given global scope so as to be accessible by linker.ld

// hard coded values
.set MB_MAGIC, 0x1BADB002 //magic constant points to kernel location
.set MB_FLAGS, (1 << 0) | (1 << 1) // GRUB 1. loads modules on page boundaries and sets up a memory map
.set MB_CHECKSUM, (0 - (MB_MAGIC + MB_FLAGS))

.section .multiboot // Multiboot header
	.align 4 // checks that data aligns on a multiple of 4 bytes
	.long MB_MAGIC
	.long MB_FLAGS
	.long MB_CHECKSUM

.section .bss // sets aside data initialized to zero
	// here we produce the stack with an allocation of 4096 bytes
	// stack is expandable
	.align 16
	stack_bottom:
		.skip 4096 // reserves 4096 byte stack
	stack_top:
	// stack struct:
		// stack_top
			// 0-
			// 1-
			// 2-
			// 3-
			// ...-
			// 4k-
		// stack_bottom

.section .text // assembly code to be run when kernel loads
	start: // first piece of code run by kernel (refers to global var start)
		// to set up C-runnable environment we must initialize the stack
		mov $stack_top, %esp //esp is top-of-stack pointer
					   //mov sets stack_top as our top-of-stack
		call kernel_main // calls main function of c file
		hang: // hangs the CPU in the event that our kernel ever returns vals
			cli // disable CPU interrupts
			hlt // halt the CPU
			jmp hang // loops hang in the event that cli and hlt fail