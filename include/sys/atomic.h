/*
 * Copyright (c) 2016 Jonathan (also known as bauen1)
 * LICENCE: MIT License (look at /LICENCE.md)
 */

#ifndef _ATOMIC_H_
#define _ATOMIC_H_

#ifdef __ASSEMBLY__

#define atomic_start() sei
#define atomic_end() cli

#else

#define atomic_start() (__asm("sei"))
#define atomic_end() (__asm("cli"))

#endif

#endif
