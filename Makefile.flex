####
# Makefile by Sam <sam(at)frida.fri.utc.sk>
#	for generation of flex based tokenizer
#
EXT	= c
FFLAGS	= -F -CFar
FLEX	= flex $(FFLAGS)
FLEX_EXT= $(EXT).flex

all: lex.tokenizer_yy.$(EXT)

lex.tokenizer_yy.$(EXT): clean tokenizer.$(FLEX_EXT)
	$(FLEX) tokenizer.$(FLEX_EXT)

.PHONY: all clean lex.tokenizer_yy.$(EXT)

clean:
	rm -f lex.tokenizer_yy.o

# FINI: makefile
