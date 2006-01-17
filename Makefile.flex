####
# Makefile by Sam <samkob<at>gmail.com>
#	for generation of flex based tokenizer
#
EXT	= c
FFLAGS	= -Cfar 
#FFLAGS	+= -p -p
FLEX	= flex $(FFLAGS)
FLEX_EXT= $(EXT).flex
O_FILE	= lex.tokenizer_yy.$(EXT)

all: $(O_FILE)

$(O_FILE): clean tokenizer.$(FLEX_EXT)
	$(FLEX) tokenizer.$(FLEX_EXT)
	mv $(O_FILE) $(O_FILE).orig
	grep -v "unistd\\.h" $(O_FILE).orig > $(O_FILE)
	rm -f $(O_FILE).orig

.PHONY: all clean $(O_FILE)

clean:
	rm -f lex.tokenizer_yy.o

# FINI: makefile
