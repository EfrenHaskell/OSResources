/* bootloader begins exection at ENTRY point (here defined as start) */
ENTRY(start)


/* sets kernel sections at positions for final kernel executable using compiler linker */
SECTIONS
{
	/* begin placing sections at 1M (1 MegaByte) as locations below 1M are reserved */
	. = 1M;
	
	/* align sections in 4K intervals so memory is paging-compatable */
	
	/* multiboot header must be placed near beginning of executable */
	/* header is Read-only data thus it is set in the .rodata section unlike bss which init.s the stack (must be written to) and text which must also be modified */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
	}
	
	/* executable code */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.text)
	}

	/* read-only data */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}
	
	/* read-write data (initialized) */
	.data Block(4K) : ALIGN(4K)
	{
		*(.data)
	}
	
	/* read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
}