/*
 * Copyright (c) 2016 Jonathan (also known as bauen1)
 * LICENCE: MIT License (look at /LICENCE.md)
 */

#ifndef _KERNEL_H_
#define _KERNEL_H_

#ifdef __ASSEMBLY__
/* Kernel API & drivers include file. */
def %print ($fe00)
def %input ($fe02)
def %strcmp ($fe04) /* not-implemented TODO: move to <string.h> */

/* TODO: move these to their own header files */
/* File I/O driver: */
def %finit ($fe20)
def %fcount ($fe22)
def %fexists ($fe24)

/* Network driver: */
def %printip ($fe40)

#endif

#endif
