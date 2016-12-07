/*
 * Copyright (c) 2016 Jonathan (also known as bauen1)
 * LICENCE: MIT License (look at /LICENCE.md)
 */

.OUT KERNEL.SYS
.ORG $f000

#include <signal.h>
#include <errno.h>
#include <color.h>
#include <sys/protect.h>
#include <sys/atomic.h>

/*------------------------------------------------------------------------------
    The *nix like kernel for hackers-edge.com
    Written by bauen1 2016

    __FILE__ compiled on __DATE__
    Compiled using __VERSION__
------------------------------------------------------------------------------*/

#if !(defined CPU_6502 || CPU_65C02)
#warning "This program should be compiled to a 6502 or 65C02 CPU !"
#endif

/*------------------------------------------------------------------------------
    Constants
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
    Kernel Init Routine
    initialises the data segment pointer loads the fileio and network drivers
------------------------------------------------------------------------------*/
_init:              jsr @reset_ds     /* set data segment to kernel data segment */

                    /* TODO: load info text from file to conserve space ? */
                    ldy #$51
                    jsr @print

                    stz $fa           /* Setup pointers */
                    lda #$f1
protect()                             /* Happy disassembling >:D */
                    sta $fb
                    stz $fc
                    lda #$fe
                    sta $fd

                    ldy #$20-1        /* buffer size */
                    JSR @memcpy

                    lda #$f1
                    sta $81

                    ldy #$23          /* FILEIO.SYS\0 */
                    sty $80
                    lda #$f2
                    jsr @load_lib

                    ldy #$2E          /* NETDRV.SYS\0 */
                    sty $80
                    lda #$f3
                    jsr @load_lib

                    lda #2
                    jsr @set_ds       /* Setup Data Segment for user code */
                    brk               /* kernel init end */
/*------------------------------------------------------------------------------
  set_ds:
  sets the data segment pointer ($f0-$f1) to po
  reset_ds:

------------------------------------------------------------------------------*/
@reset_ds:          lda #$f1
                    /* Fall-through */

@set_ds:            stz $f0
                    sta $f1
                    rts

/*------------------------------------------------------------------------------
  memset: TODO: FIXME
  sets a memoryblock to A
------------------------------------------------------------------------------*/
@memset:
_memset:            sta ($fa),Y
                    dey
                    bne _memset
                    sta ($fa),Y
                    rts


/*------------------------------------------------------------------------------
  memmove:
  copies one buffer to another possibly overlapping buffer
  TODO: actually implement this
------------------------------------------------------------------------------*/
@memmove:           /* Fall-through to memcpy */

/*------------------------------------------------------------------------------
  memcpy:
  copies one buffer to another (not overlapping) buffer
------------------------------------------------------------------------------*/
@memcpy:
_memcpy:            pha
_memcpy_loop:       lda ($fa),Y
                    sta ($fc),Y
                    dey
                    bne _memcpy_loop
                    lda ($fa),Y
                    sta ($fc),Y
                    pla
                    rts
/*------------------------------------------------------------------------------
  memchr:
  finds first occurence of A in a buffer FIXME: edge-cases ?
------------------------------------------------------------------------------*/
@memchr:
_memchr:
_memchr_loop:       cmp ($fa),Y
                    beq _memchr_done
                    dey
                    bne _memchr_loop
_memchr_done:       rts

/*------------------------------------------------------------------------------
  memcmp:
  compares two memory areas and returns 0 if they match non zero if not (in Y)
------------------------------------------------------------------------------*/
@memcmp:            pha
_memcmp_loop:       lda ($fa),Y
                    cmp ($fc),Y
                    bne _memcmp_done
                    dey
                    bne _memcmp_loop
_memcmp_done:       pla
                    rts

/*------------------------------------------------------------------------------
  strlen:
  $fa = pointer to string
  Y = string length (without 0)
------------------------------------------------------------------------------*/
@strlen:            pha
                    lda #0
                    ldy #0
                    jsr @memchr
                    dey
                    pla
                    rts

/*------------------------------------------------------------------------------
  input: TODO: free up some bytes for this
  reads a string (until newline) from the keyboard
  Y = length of input
------------------------------------------------------------------------------*/
@input:             PHA
                    PLA
                    RTS

/*------------------------------------------------------------------------------
  load_lib loads a library into memory
  Y = data segment index of name
  A = page to load in to
  data segment in $f0
  Note: $80 is changed!
  name and success/failure are printed to screen
  if success A=0 else A=errno
  TODO: FIXME: uses $03-$06 until "sta @label+2" works
------------------------------------------------------------------------------*/
@load_lib:
_load_lib:          phx
                    pha
                    atomic_start()
                    sta $F122       /* jsr_ind+2 */
                    lda $f1
                    sta $81         /* FIXME: consider $f0 too ? (= 16 bit pointer add )*/
                    sty $80
                    pla
                    stz $ff85
                    stz $ff83
                    ldx #3
                    stx $ff82
                    sta $ff84
                    ldx $ff86
                    bne _load_lib_fail
                    jsr @_load_lib_print1

                    lda $f1
                    pha
                    lda $f0
                    pha

                    ldy #$49          /* "loaded.\0"*/
                    jsr @_load_lib_print2
                    lda #10
                    sta $ffd0

@_load_lib_jsr:     jsr $F120         /* jsr_ind */

                    bra _load_lib_done

_load_lib_fail:

                    lda #FG_RED
                    sta $ffd4
                    jsr @_load_lib_print1
                    lda $f1
                    pha
                    lda $f0
                    pha
                    ldy #$39          /* "failed to load:\0"*/
                    jsr @_load_lib_print2
                    stx $ffd1         /* print error code */
                    ldy #10
                    sty $ffd0
                    ldy #FG_GREEN
                    sty $ffd4
                    /* Fall-through */

_load_lib_done:     pla
                    sta $f0
                    pla
                    sta $f1           /* restore ds pointer */
                    txa
                    plx
                    atomic_end()
                    rts

@_load_lib_print2:  jsr @reset_ds
                    /* Fall-through */
@_load_lib_print1:  jsr @print
                    lda #32
                    sta $ffd0
                    rts

/*------------------------------------------------------------------------------
  print: FIXME: uses rather limiting data segment pointer
  prints from the data segment pointer with Y as offset until a 0 is encountered
  Y = index of ending 0
------------------------------------------------------------------------------*/

@print:             pha
_print_loop:        lda ($f0),Y
                    cmp #0
                    beq _print_done
                    sta $ffd0
                    iny
                    bne _print_loop
_print_done:        pla
@free:              rts

/*------------------------------------------------------------------------------
  Data Segment: ($f100)
------------------------------------------------------------------------------*/
.PAGE
/* $00: jsr table */
DCW @print,   @input,   @free,    @free
DCW @strlen,  @free,    @free,    @free
DCW @memset,  @memcpy,  @memmove, @memcmp
DCW @memchr,  @free,    @free,    @free
/* $20*/
/* FIXME: abusing the data segment :/ */
jsr_ind:            jmp ($0000)
/* $23: */
DCS FILEIO.SYS\0
/* $2E: */
DCS NETDRV.SYS\0
/* $39: */
DCS failed to load:\0
/* $49: */
DCS loaded.\0
/* $51: motd */
DCS Copyright (c) 2016 Jonathan (also known as bauen1)\n
DCS LICENCE: MIT License (look at /LICENCE.md)\n
DCS Starting HackKernel ...\n\0
