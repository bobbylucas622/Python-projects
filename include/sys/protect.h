/*
* Copyright (c) 2016 Jonathan (also known as bauen1)
* LICENCE: MIT License (look at /LICENCE.md)
*/

#ifndef _PROTECT_H_
#define _PROTECT_H_

#ifdef __ASSEMBLY__

#define protect() DCB $80,$01,$3F
#define protect_3_bytes() protect() /* \_(^_^)_/ */

#endif

#endif
