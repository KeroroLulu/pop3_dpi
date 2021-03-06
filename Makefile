CC=gcc
CFLAGS=-W -Wall -Wextra -pedantic -Wshadow -std=gnu11
LDFLAGS=-lpcap
EXEC=pop3parser
SRC= main.c
OBJ= $(SRC:.c=.o)

all: $(EXEC)

#%.tab.c %.tab.h: %.y types.h
#	bison -d $<

#lex.yy.c: pop.l pop.tab.h types.h
#	flex pop.l

#test-parser: lex.yy.c pop.tab.c pop.tab.h
#	$(CC) -o test-parser pop.tab.c lex.yy.c

#pop3parser: lex.yy.o  pop.tab.o $(OBJ)
pop3parser: $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^ $(CFLAGS)

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

.PHONY: clean mrproper

clean:
	@rm -rf *.o *.tab.*

mrproper: clean
	@rm -rf $(EXEC)
