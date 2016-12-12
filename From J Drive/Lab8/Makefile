#####################################################################
# ECEn 425 Lab 8 Makefile

lab8.bin:	lab8final.s
		nasm lab8final.s -o lab8.bin -l lab8.lst

lab8final.s:	clib.s myisr.s myinth.s lab8app.s yaks.s
		cat clib.s simptris.s myisr.s myinth.s yakc.s yaks.s lab8app.s > lab8final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab8app.s:	lab8app.c yakc.s yakk.h
		cpp lab8app.c lab8app.i
		c86 -g lab8app.i lab8app.s

yakc.s:		yakc.c yakk.h
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab8.bin lab8.lst lab8final.s myinth.s myinth.i \
		lab8app.s lab8app.i yakc.s yakc.i
