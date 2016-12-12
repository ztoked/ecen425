#####################################################################
# ECEn 425 Lab 4C Makefile

lab4.bin:	lab4cfinal.s
		nasm lab4cfinal.s -o lab4.bin -l lab4c.lst

lab4cfinal.s:	clib.s myisr.s myinth.s lab4c_app.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s yaks.s lab4c_app.s > lab4cfinal.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab4c_app.s:	lab4c_app.c yakc.s yakk.h
		cpp lab4c_app.c lab4c_app.i
		c86 -g lab4c_app.i lab4c_app.s

yakc.s:		yakc.c yakk.h
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab4.bin lab4c.lst lab4cfinal.s myinth.s myinth.i \
		lab4c_app.s lab4c_app.i yakc.s yakc.i
