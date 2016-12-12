#####################################################################
# ECEn 425 Lab 4C Makefile

lab4.bin:	lab4dfinal.s
		nasm lab4dfinal.s -o lab4.bin -l lab4d.lst

lab4dfinal.s:	clib.s myisr.s myinth.s lab4d_app.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s yaks.s lab4d_app.s > lab4dfinal.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab4d_app.s:	lab4d_app.c yakc.s yakk.h
		cpp lab4d_app.c lab4d_app.i
		c86 -g lab4d_app.i lab4d_app.s

yakc.s:		yakc.c yakk.h
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab4.bin lab4d.lst lab4dfinal.s myinth.s myinth.i \
		lab4d_app.s lab4d_app.i yakc.s yakc.i
