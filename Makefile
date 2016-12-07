#/*
# * Copyright (c) 2016 Jonathan (also known as bauen1)
# * LICENCE: MIT License (look at /LICENCE.md)
# */

#AUTH= # format: "USER:PASSWORD"
#CC=cpp
CC=gcc
FTP=curl

CPREFLAGS=-E -P -Wall -DCPU_65C02 -D__ASSEMBLY__ -nostdinc -I./include

FTPSERVER=ftp://hackers-edge.com:2121/
FTPPATH=/
FTPFLAGS=
FTPUPLOAD= \
	$(ifndef AUTH\
		error "AUTH is not set! Example: 'make all AUTH=user:password' to disable ftp upload use 'make all NOFTPUPLOAD=true'") \
		$(FTP) --user $(AUTH) $(FTPFLAGS) -T $< $(FTPSERVER)$(FTPPATH)

# TODO: generate dependencys (header files) and use them!

.DEFAULT: info
.PHONY: info
info:
	@echo "HackKernel:"
	@echo "Available targets:"
	@echo "clean all"

ifdef NOFTPUPLOAD
FTPUPLOAD=@echo ""
endif

#ifndef AUTH
#$(error "AUTH is not set! Example: make all AUTH=user:password")
#endif

.PHONY: clean
clean:
	@echo "Cleaning..."
	rm *.i
	rm kernel
	rm fileio
	rm netdrv
	@echo "Finished..."

.PHONY: all
all: kernel fileio netdrv misc

misc:	LICENCE.md
	$(FTPUPLOAD)
	echo "uploaded LICENCE.md" > misc

kernel:	kernel.i
	$(FTPUPLOAD)
	echo "uploaded kernel" > kernel

fileio: fileio.i
	$(FTPUPLOAD)
	echo "uploaded fileio" > fileio

netdrv: netdrv.i
	$(FTPUPLOAD)
	echo "uploaded netdrv" > netdrv

%.i: %.asm include/%.h
	$(CC) $(CPREFLAGS) $< | ./shorter.lua > $@
