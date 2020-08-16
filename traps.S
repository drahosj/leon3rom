.section ".text","ax"

.global trap_overflow
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

.global trap_underflow
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
