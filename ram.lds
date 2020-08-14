MEMORY
{
    ram (rwx)   : ORIGIN = 0xa0000000, LENGTH = 0x4000
}

SECTIONS
{
        .head : {
        _start = .;
                KEEP(*(.head))
        } > ram

        .text : ALIGN(0x1000) { *(.text) } > ram
        .rodata : { 
            *(.rodata);
            *(.rodata.*);
            . = ALIGN(4);
            _erodata = .;
        } > ram

        .data : { 
            . = ALIGN(4);
            _data = .;
            *(.data);
            . = ALIGN(4);
            _edata = .; 
        } > ram

        .bss (NOLOAD) : { 
            . = ALIGN(4);
            _bss = .;
            *(.bss);
            *(COMMON);
            . = ALIGN(4);
            _ebss = .;
        } > ram
}

ENTRY(_start);
