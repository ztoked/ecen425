#####################################################################
# ECEn 425 Lab 4B Makefile

lab4B.bin:	lab4Bfinal.s
		nasm lab4Bfinal.s -o lab4B.bin -l lab4B.lst

lab4Bfinal.s:	clib.s myisr.s myinth.s lab4b_app.s yaks.s 
		cat clib.s myisr.s myinth.s yakc.s yaks.s lab4b_app.s > lab4Bfinal.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab4b_app.s:	lab4b_app.c yakc.s yakk.h
		cpp lab4b_app.c lab4b_app.i
		c86 -g lab4b_app.i lab4b_app.s

yakc.s:		yakc.c yakk.h
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab4B.bin lab4B.lst lab4Bfinal.s myinth.s myinth.i \
		lab4b_app.s lab4b_app.i yakc.s yakc.i
