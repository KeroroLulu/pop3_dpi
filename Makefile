CC=gcc
CFLAGS=-W -Wall
LDFLAGS=-lpcap
EXEC=pop3parser
SRC= main.c
OBJ= $(SRC:.c=.o)

all: $(EXEC)

pop3parser: $(OBJ)
	@$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	@$(CC) -o $@ -c $< $(CFLAGS)

.PHONY: clean mrproper

clean:
	@rm -rf *.o

mrproper: clean
	@rm -rf $(EXEC)
