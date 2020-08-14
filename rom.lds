MEMORY
{
    ram (rwx)   : ORIGIN = 0xa0000000, LENGTH = 0x4000
    rom (rx)    : ORIGIN = 0x00000000, LENGTH = 0x4000
}

SECTIONS
{
        . = 0x00000000;
        _start = .;
        .head : {
                KEEP(*(.head))
        } > rom

        .text : ALIGN(0x1000) { *(.text) } > rom
        .rodata : { 
            *(.rodata);
            *(.rodata.*);
            . = ALIGN(4);
            _erodata = .;
         } > rom

        .data : { 
            . = ALIGN(4);
            _data = .;
            *(.data);
            . = ALIGN(4);
            _edata = .; 
        } > ram AT > rom

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
