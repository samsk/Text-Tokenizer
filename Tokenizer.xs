#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <tokenizer.h>

/*fixups*/
#define	TOK_UNDEF	0
#define	TOK_TEXT	1
#define	TOK_DQUOTE	2
#define	TOK_SQUOTE	3
#define	TOK_IQUOTE	4
#define	TOK_SIQUOTE	5
#define	TOK_BLANK	6
#define	TOK_ERROR	7
#define	TOK_EOL		8
#define	TOK_COMMENT	9
#define	TOK_EOF		EOF

#define	NOERR		0
#define	UNCLOSED_DQUOTE	1
#define	UNCLOSED_SQUOTE	2
#define	UNCLOSED_IQUOTE	3
#define	NOCONTEXT	4

#include "const-c.inc"

/*internal functions*/
tok_buf *_Tokenizer_tokb_new()
{
	return (tok_buf *) newSV(0);
}

void _Tokenizer_tokb_clear(tok_buf *buf)
{
	sv_setpv((SV *)buf, "");
	return;
}

void _Tokenizer_tokb_put(tok_buf *buf, char *str, unsigned int len)
{
	sv_catpvn((SV *) buf, str, len);
	return;
}

void _Tokenizer_tokb_del(tok_buf *buf)
{
	sv_2mortal((SV *) buf);
	return;
}

void _Tokenizer_tokb_init()
{
	struct tok_buffer *tb	= (struct tok_buffer *) safemalloc(sizeof(struct tok_buffer));

	tb->ts_new	= _Tokenizer_tokb_new;
	tb->ts_clear	= _Tokenizer_tokb_clear;
	tb->ts_put	= _Tokenizer_tokb_put;
	tb->ts_del	= _Tokenizer_tokb_del;
	tokenizer_setcb(tb);
	return;
}


MODULE = Text::Tokenizer		PACKAGE = Text::Tokenizer

INCLUDE: const-xs.inc

PROTOTYPES: DISABLE

BOOT:
	_Tokenizer_tokb_init();


int
tokenizer_options(opts)
	int	opts
	CODE:
		{
			RETVAL	= tokenizer_options(opts);
		}
	OUTPUT:
		RETVAL


int
tokenizer_new(input)
	FILE *	input
	CODE:
		{
			RETVAL	= (int) tokenizer_new(input);
		}
	OUTPUT:
		RETVAL


int
tokenizer_new_strbuf(str, len)
	char *		str
	unsigned int	len
	CODE:
		{
			RETVAL	= (int) tokenizer_new_strbuf(str, len);
		}
	OUTPUT:
		RETVAL

void
tokenizer_scan()
	INIT:
		tok_retval	token;
	PPCODE:
		{


			/*scan buffer*/
			tokenizer_scan(&token);

			/*return array*/
			/*XXX: token.buffer should point to an growing SV
			 *	so I hope newSVsv copies only existing length
			 *	of SV and not whole SV	*/
			XPUSHs(sv_2mortal(newSVsv((SV *)token.buffer)));/*string*/
			XPUSHs(sv_2mortal(newSViv(token.token)));	/*type*/
			XPUSHs(sv_2mortal(newSViv(token.line)));	/*line*/
			if(token.error != NOERR)		
			{
				XPUSHs(sv_2mortal(newSViv(token.error)));		/*error*/
				XPUSHs(sv_2mortal(newSViv(token.error_line)));	/*error line*/
			}
		}

int
tokenizer_exists(buffer)
	int	buffer
	CODE:
		{
			RETVAL	= (int) tokenizer_exists((tok_id) buffer);
		}
	OUTPUT:
		RETVAL

int
tokenizer_switch(buffer)
	int	buffer
	CODE:
		{
			RETVAL	= (int) tokenizer_switch((tok_id) buffer);
		}
	OUTPUT:
		RETVAL

int
tokenizer_delete(buffer)
	int	buffer
	CODE:
		{
			RETVAL	= (int) tokenizer_delete((tok_id) buffer);
		}
	OUTPUT:
		RETVAL

int
tokenizer_flush(buffer)
	int	buffer
	CODE:
		{
			RETVAL	= (int) tokenizer_flush((tok_id) buffer);
		}
	OUTPUT:
		RETVAL

int
tokenizer_destroy()
	CODE:
		{
			RETVAL	= (int) tokenizer_destroy();
		}
	OUTPUT:
		RETVAL
