#include "task.h"

.global utl_compute_mask
utl_compute_mask:
    set     _nwin, %l0
    ld      [%l0], %l1      ! _nwin in %l1
    set     _ctid, %l0
    ld      [%l0], %l2      ! _ctid in %l2

    add     %g0, 0, %l3     ! i in %l3
    add     %g0, 0, %l4     ! build wim in %l4

    set     _wtab, %l5      ! wtab in %l5
loop_entry:
    sll     %l3, 2, %l0
    ld      [%l5 + %l0],  %l0   ! wtab[i] in %l0
    cmp     %l0, %l2
    be      skip_invalid    
    nop                     ! win[i] belongs to other task
    set     1, %l0
    sll     %l0, %l3, %l0   ! Shift in bit to mask
skip_invalid:
    deccc   %l3
    bnz     loop_entry:
    or      %l0, %l4, %l4   ! wim |= (1 << i) 

    mov     %l4, %l0
