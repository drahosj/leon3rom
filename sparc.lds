SECTIONS
{
        . = 0x00;
        _start = .;
        .head : {
                KEEP(*(.head))
        }
        . = 0x2000;
        .trap_table : {*(.trap_table)}
        . = 0x3000;
        .text : { *(.text) }
        .rodata : { *(.data) }
}

