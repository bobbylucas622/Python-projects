/*
 * Copyright (c) 2016 Jonathan (also known as bauen1)
 * LICENCE: MIT License (look at /LICENCE.md)
 */

.OUT FILEIO.SYS
.ORG $f200
.TYP RAW

#include <fileio.h>
#include <errno.h>
#include <kernel.h>

DCW @init
DCW @jsr_table

@version_text:
DCS HackFileIO v0.1\n\0

@jsr_table:
DCW @finit, @fcount, @fexists, $0000

@init:              stz $f0
                    lda #$f2
                    sta $f1
                    ldy #4
                    jsr %print
                    RTS

@finit:             /* Fall-through */

@fcount:            /* Fall-through */

@fexists:           RTS

/*.PAGE*/ /* fill remaining room with 0s */
