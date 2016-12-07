/*
 * Copyright (c) 2016 Jonathan (also known as bauen1)
 * LICENCE: MIT License (look at /LICENCE.md)
 */

.OUT NETDRV.SYS
.ORG $f300
.TYP RAW

#include <netdrv.h>
#include <errno.h>
#include <kernel.h>

DCW @init
DCW @jsr_table

@version_text:
DCS HackNetDrv v0.1\n\0

@ip:
DCS IP:
DCB $20 /* " " */
DCB $00

@jsr_table:
DCW @printip, $0000

@init:              stz $f0
                    lda #$f3
                    sta $f1
                    ldy #4
                    jsr %print
                    /* Fall-through */

@net_init:          lda #$e0
                    sta $ff70
                    ldy #$15
                    jsr %print
                    ldy #0
                    jsr @printip
                    lda #10
                    sta $ffd0
                    rts
/* size: 33 vs 26 */
@printip:           pha
                    phy
                    jsr @_print_seg
                    jsr @_print_seg
                    jsr @_print_seg
                    lda $E000,Y
                    sta $ffd1
                    ply
                    pla
                    RTS

@_print_seg:        lda $E000,Y
                    sta $ffd1
                    lda #"."
                    sta $ffd0
                    iny
                    rts

/*.PAGE */ /* fill remaining room with 0s */
