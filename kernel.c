// available for freestanding C
#include <stddef.h>
#include <stdint.h>

// macros to check if x86-elf cross-compiler is functioning properly
#if defined(_linux_) // not sure if this line applies because I use windows os
	#error "Requires cross-compiler"
#elif !defined(_i386_)
	#error "Requires x86-elf compiler"

// vga textmode buffer used to display text (must be written to this memory location)
// volatile keyword indic. value may change at any time wout any action taken by compiled code
// uint16_t - data-type equiv. of an unsigned short (short takes 16 bits of memory) -- uint8_t = char, uint32_t = int, uint_64_t = long
// * denotes a pointer variable (vga_buffer will store an address rather than data)
volatile uint16_t* vga_buffer = (uint16_t*)0xB8000; // 0xB8000 is mem location of vga buffer

// allocate VGA buffer size (80x25 chars)
const int VGA_COLS = 80;
const int VGA_ROWS = 25;

// text display pos. (top-left -- column = 0, row = 0)
int term_col = 0;
int term_row = 0;
// set terminal to black background, white foreground
uint8_t term_color = 0x0F; // 0x0F is hex for bin. 0000 1111 -- I assume 0000 reps. black and 1111 reps. white

// function clears terminal to allow for initialization
void term_init()
{
	// iterate through textmode buffer
	for (int col = 0; col < VGA_COLS; col++)
	{
		for (int row = 0; row < VGA_ROWS; row++)
		{
			// determine index within the buffer to place char
			// size_t sets aside max storage for index var
			// (VGA_COLS * row) each row it. moves index to the next row in col (col) moves index to the next col it.
			// vga buffer iteration:
			// col: 0       1     2 3 4 5 6 7 8 ... 79
			// row: 0 80
			//      1  160  161   ...               239
			//      2  240  241   ...               319
			//	 3  320  321   ...               399
			//	 4  400  401   ...               479
			//	 5  480  481   ...               559
			//	 6  560  561   ...               639
			//	 ...
			//	 24 1920 1921  ...               1999
			const size_t index = (VGA_COLS * row) + col;
			// VGA buffer entries arranged as such -- BBBBFFFFCCCCCCCC:
			// - B = Background Color
			// - F - Foreground Color
			// - C = ASCII for char
			// << left-shift operand shifts our 'C' val (here ' ') over 8 bits
			// (uint16_t) casts term_color + char ' ' to a 16 bit data block
			vga_buffer[index] = ((uint16_t)term_color << 8) | ' ';
		}
	}
}

void term_putc(char c)
{
	// for scroll-resetting terminal imp. -- if scroll imp. is not desired, an alt. is included below labeled alt.
	// tests if col and row have reached the end of VGA col and VGA row (end of VGA buffer) -- pushes all vals up 1 row
	if (term_row >= VGA_ROWS)
	{
		// iterates through our vga_buffer
		for(int col = 0; col < VGA_COLS; col++)
		{
			// iterate rows until 1 before last VGA_ROWS
			for(int row = 1; row < VGA_ROWS - 1; row++)
			{
				const index = (VGA_COLS + row) + col; // grab advance index (adv. row)
				const prev_index = (VGA_COLS + row - 1) + col; // grab previous index (row - 1)
				vga_buffer[prev_index] = vga_buffer[index]; // place advance index at pos. of previous index

			}
			// handle last row
			const index = (VGA_COLS + row + 1) + col;
			vga_buffer[index] =  ' ';
		}
	}

	// switch - case = logical operation that tests for equality against case values
	// here we use case '\n' to check if char c == '\n' (line break)
	// if so, rather than add '\n' to our vga buffer we move to the next row in col 0 (start of line (row))
	switch (c)
	{
		case '\n':
		{
			term_col = 0;
			term_row ++;
			break;
		}
		// default as name inplies handles all default cases where char c != '\n'
		default:
		{
			const size_t index = (VGA_COLS * term_row) + term_col; // same struct used to it. when clearing/init. terminal
			vga_buffer[index] = ((uint16_t)term_color << 8) | c;
			term_col++; // move column over 1 after setting new char val
			break;
		}
	}
	// tests if col has reached the end of our VGA col -- resets the col and moving to the next row (term_row++) if so
	if (term_col >= VGA_COLS)
	{
		term_col = 0;
		term_row++;
	}

	// alt.
	// tests if col and row have reached the end of VGA col and VGA row (end of VGA buffer) -- resets col and row if so
	// if (term_row >= VGA_ROWS)
	// {
	//	 term_col = 0;	
	//	 term_row = 0;
	// }
	
}


// to print an entire string onto the screen
void term_print(const char* str)
{
	for(size_t i = 0; str[i] != '\0'; i++) // it. till str[i] reaches null-terminating char '\0' -- similar to hasnext()
	{
		term_putc(str[i]); // grab and put each char in str
	}
}

// kernel main function
void kernel_main()
{
	term_init(); // init. terminal
	
	// display messages
	term_print("Kernel is functional--\n");
	term_print("Hello, World!");
}