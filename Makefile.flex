####
# Makefile by Sam <_samkob_(a)_gmail_._com_>
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
	$(FLEX) --nounistd tokenizer.$(FLEX_EXT)
	rm -f $(O_FILE).orig

.PHONY: all clean $(O_FILE)

clean:
	rm -f lex.tokenizer_yy.o

# FINI: makefile
