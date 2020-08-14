#include "prom.h"
#include "soc.h"
#define OCMSTART 0xA0000000
#define OCMSIZE  0x4000
#define USE_OCM 1

.macro  PUTC c
    set \c, %o0
    call early_putc
    nop
.endm

.macro PUTS s
    set \s, %o0
    call early_puts
    nop
.endm

	.seg	"text"
	.align	4
	.global start
.section ".head","ax"
start:

	flush
	set  0x81000f, %g1
	sta %g1, [%g0] 2    ! enable caches
	set 0x10e0, %g1		! (EF S PS ET) - FP, traps, set supervisor mode
	mov %g1, %psr
	mov %g0, %wim
	mov %g0, %tbr
	mov %g0, %y
	mov %g0, %asr16
    set 0xDEADBEEF, %g0
    set 0xFEEDBEEF, %g1

	nop

    set UART_BASE, %g1
    set UART_SCALE_9600, %g2
    st  %g2, [%g1 + 0x0c]

    set 3, %g2
    st  %g2, [%g1 + 0x08]

    PUTC 'L'
    PUTC 'E'
    PUTC 'O'
    PUTC 'N'

    PUTS s_banner1
    PUTS s_banner2
    PUTS s_banner3
    PUTS s_banner4
    PUTS s_date
    PUTC ' '
    PUTS s_time
    PUTS s_banner5

    set 'p', %o0
    call leon_putc
    set 'u', %o0
    call leon_putc
    set 't', %o0
    call leon_putc
    set 'c', %o0

    ba resume_init
    nop

halt:
    ba halt
    nop

early_strcpy:
    ldub [%o0], %o2
    stub %o2, [%o1]
    tst %o2
    bnz,a early_strcpy
    add %o0, 1, %o0
    retl
    nop

.global early_putc
early_putc:
    set UART_BASE, %o6
tst:
    ld  [%o6 + 0x4], %o5
    andcc   %o5, 0x04, %g0
    be  tst
    nop
    st  %o0, [%o6]
    retl
    nop

early_puts:
    mov %o0, %o4
    mov %o7, %o3
early_puts_loop:
    ldub [%o4], %o0
    tst %o0
    bz  end_early_puts
    nop
    call early_putc
    add %o4, 1, %o4
    ba early_puts_loop
end_early_puts:
    mov %o3, %o7
    retl
    nop


resume_init:
#ifdef DSUADDR
    PUTS s_dsuinit
	set	DSUADDR, %g2
	st	%g0, [%g2]
	st	%g0, [%g2+0x08]
	st	%g0, [%g2+0x20]
	st	%g0, [%g2+0x24]
	st	%g0, [%g2+0x40]
	st	%g0, [%g2+0x44]
	st	%g0, [%g2+0x50]
	st	%g0, [%g2+0x54]
	st	%g0, [%g2+0x58]
	st	%g0, [%g2+0x5C]
	st	%g0, [%g2+0x54]
    PUTS s_done
#endif

    PUTS s_regsinit
2:
	mov %asr17, %g3
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
	mov %g0, %g7
1:
	mov %g0, %l0
	mov %g0, %l1
	mov %g0, %l2
	mov %g0, %l3
	mov %g0, %l4
	mov %g0, %l5
	mov %g0, %l6
	mov %g0, %l7
	mov %g0, %o0
	mov %g0, %o1
	mov %g0, %o2
	mov %g0, %o3
	mov %g0, %o4
	mov %g0, %o5
	mov %g0, %o6
	mov %g0, %o7
    PUTC '>'
	subcc %g3, 1, %g3
	bge 1b
	save
    PUTC ' '
    PUTC '-'
    PUTC ' '
    PUTS s_done

    PUTS s_checkfpu
	mov %psr, %g1
	srl %g1, 12, %g1
	andcc %g1, 1, %g0
	be 1f
	nop

    PUTS s_fpuinit
	set _fsrxx, %g3
	ld [%g3], %fsr
	ldd [%g3], %f0
	ldd [%g3], %f2
	ldd [%g3], %f4
	ldd [%g3], %f6
	ldd [%g3], %f8
	ldd [%g3], %f10
	ldd [%g3], %f12
	ldd [%g3], %f14
	ldd [%g3], %f16
	ldd [%g3], %f18
	ldd [%g3], %f20
	ldd [%g3], %f22
	ldd [%g3], %f24
	ldd [%g3], %f26
	ldd [%g3], %f28
	ldd [%g3], %f30
	nop
	nop
	nop
	nop
	nop
	faddd %f0, %f2, %f4
	nop
	nop
	nop
	nop
    PUTS s_done
	ba  1f	
	nop
	
	
.align	8
_fsrxx:
	.word 0
	.word 0

1:
    PUTS s_checkindex
	mov %asr17, %g3
	srl %g3, 28, %g3
	and %g3, 0x0f, %g3
    call early_putc
    add %g3, 0x30, %o0
    PUTC '\n'
    tst %g3
	bne 1f
    nop
    PUTS s_index0

#ifdef USE_OCM
    ba skip_ddr2init
    nop
#endif

#ifdef DDR2CTRLIO
    PUTS s_ddrinit
    set DDR2CTRLIO, %g1
    !set DDR2CFG1, %g2
    !st  %g2, [%g1]
    !set DDR2CFG3, %g2
    !st  %g2, [%g1+0x8]
    !set DDR2CFG4, %g2
    !st  %g2, [%g1+0xc]
    !set DDR2CFG5, %g2
    !st  %g2, [%g1+0x10]
    ld  [%g1], %g2

    set  0x10000, %g1
    or   %g2, %g1, %g2
    set DDR2CTRLIO, %g1
    st   %g2, [%g1]
    PUTS s_done

    PUTS s_memtest1
    set s_success, %o0
    call early_strcpy
    set RAMSTART, %o1

    call early_puts
    set RAMSTART, %o0

    PUTS s_memtest1done

    PUTS s_memtest2

    set s_success, %o0
    call early_strcpy
    set RAMSTART+RAMSIZE-64, %o1

    nop
    PUTC '.'
    PUTC '.'
    PUTC '\n'
    nop

    call early_puts
    set RAMSTART+RAMSIZE-64, %o0

    PUTS s_memtest2done

    set RAMSTART, %o0

    PUTC '-'
    set 0xdeadbeef, %o1
    st  %o1, [%o0]
    PUTC '|'
    ld  [%o0], %o2
    subcc %o1, %o2, %g0
    bne memtest_failed
    nop

    PUTC '-'
    set 0xfeedbeef, %o1
    st  %o1, [%o0]
    PUTC '|'
    ld  [%o0], %o2
    subcc %o1, %o2, %g0
    bne memtest_failed
    nop

    PUTC '-'
    set 0xdeadbeef, %o1
    st  %o1, [%o0 + 4]
    PUTC '|'
    ld  [%o0 + 4], %o2
    subcc %o1, %o2, %g0
    bne memtest_failed
    nop

    PUTC '-'
    set 0xfeedbeef, %o1
    ld  [%o0], %o2
    subcc %o1, %o2, %g0
    bne memtest_failed
    nop

    PUTC '|'
    set 0xdeadbeef, %o1
    ld  [%o0 + 4], %o2
    subcc %o1, %o2, %g0
    bne memtest_failed
    nop

    PUTS s_memsuccess
    ba  memtest_end
    nop
memtest_failed:
    PUTS s_memfailure
memtest_end:
    PUTS s_memtestend
    
    
    nop
#endif

skip_ddr2init:

    PUTS s_l2minit
	set L2MCTRLIO, %g1
	set MCFG1, %g2
	st  %g2, [%g1]
	set MCFG2, %g2
	st  %g2, [%g1+4]
	set MCFG3, %g2
	st  %g2, [%g1+8]
!	set IRQCTRL, %g1
!	set 0x0ffff, %g2
!	st  %g2, [%g1+0x10]
    PUTS s_done

#ifdef ASDCFG
#ifndef SDCTRLPNP
#define SDCTRLPNP 0xFFFFF860
#endif
    PUTS s_sdinit
	set SDCTRLPNP, %g1
	ld  [%g1], %g2
	srl %g2, 12, %g2
	set 0x01009, %g1
	subcc %g1, %g2, %g0
	bne 1f

	set ASDCFG, %g1
	set DSDCFG, %g2
	st  %g2, [%g1]
    PUTS s_done
#endif

#ifdef USE_OCM
    ba skip_stacksetup
    nop
#endif

	! %g3 = cpu index
#define STACKSIZE 0x2000
1:  PUTS s_beginstack
	set STACKSIZE, %g2
    mov %g0, %g1
2:	subcc %g3, 0, %g0
	be 3f
	nop
	add %g1, %g2, %g1
	ba 2b
	sub %g3, 1, %g3
	sub %fp, %g1, %fp

    ! Can't call early functions any more since they violate the stack pointer

3:	set RAMSTART+ RAMSIZE-32, %fp
skip_stacksetup:
#ifdef USE_OCM
    ! fuckit, use OCM
    set OCMSTART+OCMSIZE-32, %fp
#endif
	sub %fp, 96, %sp

	mov	2, %g1
	mov	%g1, %wim
    set trap_table, %g1
    wr  %g1,%tbr
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;

    set OCMSTART, %g1
    set 0xdeadbeef, %g2
    st  %g2, [%g1]

    call c_start
    nop

    ! Jump to RAM
    ba halt
	set RAMSTART, %g1

	jmp %g1
	nop

.macro GENTRAP l
    sethi %hi(\l), %l0
    or  %l0, %lo(\l), %l0
    jmp %l0
    nop
.endm

trap_unimp:
    ba trap_unimp
    nop

trap_overflow:
    wr      %g0, %wim           ! nuke WIM (will set it later)
    save                        ! rotate to next window (to spill)
                    
    st      %i0, [%sp + 0x00]   ! spill window
    st      %i1, [%sp + 0x04]
    st      %i2, [%sp + 0x08]
    st      %i3, [%sp + 0x0c]
    st      %i4, [%sp + 0x10]
    st      %i5, [%sp + 0x14]
    st      %i6, [%sp + 0x18]
    st      %i7, [%sp + 0x1c]
    st      %l0, [%sp + 0x20]
    st      %l1, [%sp + 0x24]
    st      %l2, [%sp + 0x28]
    st      %l3, [%sp + 0x2c]
    st      %l4, [%sp + 0x30]
    st      %l5, [%sp + 0x34]
    st      %l6, [%sp + 0x38]
    st      %l7, [%sp + 0x3c]

    rd      %psr, %i0           ! grab CWP while we're here
    and     %i0, 0x1f, %i0

    restore                     ! Rotate back to trap "window"
                                
    set     0x01, %l0           ! Set new WIM to point to "saved" window
    sll     %l0, %o0, %l0
    wr      %l0, %wim

    jmpl    %r17,%r0
    rett    %r18

trap_underflow:
    wr      0, %wim           ! Nuke WIM
    nop
    nop
    nop

    restore                     ! Rotate to invalid window
    restore

    restore                     ! Rotate one further to get new CWP
    rd      %psr, %o0           ! grab CWP of window that will become invalid
    and     %o0, 0x1f, %o0      ! Using O regs because we are about to load them
    set     1, %o1
    sll     %o1, %o0, %o1

    save                        ! Rotate back to invalid window
    mov     %i1, %o1            ! Forward new WIM value (This may break ABI if
                                ! somehow a RETT, rather than a restore, results
                                ! in underflow. That seems impossible, though,
                                ! - at least with >2 windows and lazy window
                                ! allocation.)

    ld      [%sp + 0x00], %i0   ! Load window
    ld      [%sp + 0x04], %i1   
    ld      [%sp + 0x08], %i2   
    ld      [%sp + 0x0c], %i3   
    ld      [%sp + 0x10], %i4   
    ld      [%sp + 0x14], %i5   
    ld      [%sp + 0x18], %i6   
    ld      [%sp + 0x1c], %i7
    ld      [%sp + 0x20], %l0
    ld      [%sp + 0x24], %l1   
    ld      [%sp + 0x28], %l2   
    ld      [%sp + 0x2c], %l3   
    ld      [%sp + 0x30], %l4   
    ld      [%sp + 0x34], %l5   
    ld      [%sp + 0x38], %l6   
    ld      [%sp + 0x3c], %l7   

    save                        ! Two rotates back to trap window
    mov     %i1, %o1            ! forward new WIM value. Maybe dangerous,
                                ! but less so as the returning
                                ! function is done using it's i and o
                                ! registers.
    save
    wr      %i1, %wim           ! set WIM now. Whole mess was just to avoid
                                ! doing math here.

    jmpl    %r17,%r0
    rett    %r18

trap_irq:
    jmpl    %r17,%r0
    rett    %r18

trap_inst:
    jmpl    %r17,%r0
    rett    %r18

.align(0x1000)
trap_table:
    GENTRAP start
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_overflow
    GENTRAP trap_underflow
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp
    GENTRAP trap_unimp  !0x10

! 0x11-0x1f (IRQs)
.rept 15 
    GENTRAP trap_irq
.endr

! 0x20-0x7f
.rept 0x60
    GENTRAP trap_unimp
.endr
! 0x80-0xff
.rept 0x80
    GENTRAP trap_inst
.endr

.section ".rodata"
s_hello:
    .string "Hello world\r\n"
s_banner1:
    .string "\r\n"
s_banner2:
    .string "=======================================\n"
s_banner3:
    .string "| LEON 3 BOOT ROM \n" 
s_banner4:
    .string "| Build: " 
s_date:
    .string __DATE__
s_time:
    .string __TIME__
s_banner5:
    .string "\n| Early boot (no memory initialized)\n\n"  
s_done:
    .string "Done!\n"
s_dsuinit:
    .string " - Initializing DSU registers..."
s_regsinit:
    .string " - Initializing register windows "
s_checkfpu:
    .string " - Checking FPU enabled in PSR"
s_fpuinit:
    .string " - Initializing FP registers..."
s_checkindex:
    .string " - CPU index: "
s_index0:
    .string " - Main core, doing one-time init.\n"
s_ddrinit:
    .string " - Initializing DDR..."
s_l2minit:
    .string " - Initializing L2M..."
s_sdinit:
    .string " - Initializing SD..."
s_beginstack:
    .string " - Setting stack pointer based on CPU index..."
s_memtest1:
    .string " - Simple memtest - beginning of DDR: "
s_memtest1done:
    .string " - Beginning of RAM didn't cause a halt.\n"
s_memtest2:
    .string " - Simple memtest - end of DDR: "
s_memtest2done:
    .string " - End of RAM didn't cause a halt.\n "
s_memsuccess:
    .string " - Wrote and read back the correct value. Good.\n"
s_memfailure:
    .string " - !!! RAM MEMTEST FAILURE !!! \n"
s_memtestend:
    .string " - All memtesting completed, going to leave early env soon\n"
s_earlydone:
    .string " - Setting stack pointer, transitioning out of early boot!\n"
s_success:
    .string "SUCCESS\n"

    .align 4
    
    
    

.align	32
