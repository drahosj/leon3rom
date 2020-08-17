.extern _ctid
.extern _nwin
.extern _wtab

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

    restore                     ! Rotate back to trap "window"

    rd      %psr, %o0           ! grab CWP (of trap window - not new wraparound)
    and     %o0, 0x1f, %o0

                                ! Take ownership of this window in wtab
    set     _ctid, %l0          
    ld      [%l0], %l1          ! CTID to %l1

    sll     %o0, 2, %l2         ! Offset for wtab load - cwp << 2
    set     _wtab,  %l0
    st      [%l0 + %l2], %l1    ! Write CTID to wtab entry

    call    utl_compute_mask    ! Call mask computation subroutine (not fn)
    nop

                                ! Hack - Force set WIM on next window,
                                ! in case of wraparound to same-task window,
                                ! ie. this task owns all windows, still needs
                                ! to trigger overflow on next save
    save
    rd      %psr, %o0
    and     %o0,0x1f,%o0    
    restore                     ! Grab CWP of next window
    set     1, %l1
    sll     %l1, %o1, %l1       ! Turn into mask
    or      %l0, %l1, %l0       ! Add bit to new WIM

    mov     %l0, %wim           ! Set new WIM

    jmpl    %r17, %r0
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

    set     _ctid, %l0
    ld      [%l0], %l0
    set     _wtab, %l1
    ld      [%l1], %l1
    
    wr      %i1, %wim           ! set WIM now. Whole mess was just to avoid
                                ! doing math here.

    jmpl    %r17,%r0
    rett    %r18
