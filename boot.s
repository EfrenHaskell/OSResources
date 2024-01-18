/* Both boot and boot2 files are files used by the bootloader for multibooting
They produce the groundworks of bootloading called the multiboot header
These files provide the necessary parameter acquisitions and stack allocations
necessary for the bootloader to function */

/* Constants are declared with set operation or equivalently equ "ALIGN equ 1<<0"
	-- These constants are necessary for multiboot header */
.set ALIGN, 1<<0	/* aligns modules to page boundaries "<< represents a bit shift 
			operator here 1<<0 shifts the value 1 by 0 bits" 
			The line is simply placing value 1 to property ALIGN*/
.set MEMINFO, 1<<1	/* creates a memory map, setting the variable to 2 bits
			"1<<1 produces 1 x 2^1 which equals 2" */

.set FLAGS, ALIGN | MEMINFO	// Multiboot flag parameter FLAGS
.set MAGIC, 0x1BADB002	/* sets magic number locating multiboot header (multiboot header 
				allows boot loader to lowad OS images without having to 
				understand other OS  formats*/
.set CHECKSUM, -(MAGIC + FLAGS)	// determines that the program is multiboot
.section .multiboot	// multiboot header declaration
.align 4	// align directive provides 4-byte padding for the multiboot header
.long MAGIC	// tells assembler to set aside 4 bytes of data for the MAGIC variable
.long FLAGS	// sets aside 4 bytes for the FLAGS variable
.long CHECKSUM	// sets aside 4 bytes for CHECKSUM

.section .bss	// unitialized memory
.align 16	/* sets 16-byte padding to meet System V ABI standard
			-- compiler necessitates proper alignment to function */
stack_bottom:
.skip 16384	// reserves 16384 or 16 KiB for the stack (between bp bottom and sp top)
stack_top:

.extern kernel_main // get external c-program for kernel implementation
.section .text
.global _start // creates global access to _start label identifying entry point
.type _start, @function
_start:
	mov esp, stack_top 	// sets stack pointer
	call kernel_main	// can call our c program now that the stack is initialized
	cli	// cli clears the interrupt flag (makes CPU ignore maskable interrupts)
1:	hlt	/* hlt command used to terminate program -- is used over sys_exit as 
		syscalls have yet to be bootstrapped
		(in general assembly programming hlt is deprecated I believe) */

	jmp 1	// infinitely loops in the event that hlt fails