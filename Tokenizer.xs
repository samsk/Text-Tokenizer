/* Tokenizer.xs
 *	-- perl module for fast lexical analyzation based on FLEX parser
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 * 
 *  Copyright 2003-2004 Sam <sam@frida.fri.utc.sk>
 *
*/

#ifdef __cplusplus
extern "C" {
#endif

/*perl includes*/
#define PERL_NO_GET_CONTEXT     /* we want efficiency (powered by perlguts)*/
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef __cplusplus
}
#endif

/*code header file*/
#include "tokenizer.h"

/*enum->constants hack (for const-c.inc to work)*/
#define TOK_UNDEF	TOK_UNDEF_v
#define TOK_TEXT	TOK_TEXT_v
#define TOK_DQUOTE	TOK_DQUOTE_v
#define TOK_SQUOTE	TOK_SQUOTE_v
#define TOK_IQUOTE	TOK_IQUOTE_v
#define TOK_SIQUOTE	TOK_SIQUOTE_v
#define TOK_BLANK	TOK_BLANK_v
#define TOK_COMMENT	TOK_COMMENT_v
#define TOK_ERROR	TOK_ERROR_v
#define TOK_EOL		TOK_EOL_v
#define TOK_EOF		TOK_EOF_v
#define NOERR		NOERR_v
#define UNCLOSED_DQUOTE	UNCLOSED_DQUOTE_v
#define UNCLOSED_SQUOTE	UNCLOSED_SQUOTE_v
#define UNCLOSED_IQUOTE	UNCLOSED_IQUOTE_v
#define NOCONTEXT	NOCONTEXT_v

/*package header files*/
#include "ppport.h"
#include "const-c.inc"

/*internal functions*/
static tok_buf *_Tokenizer_tokb_new(pTHX)
{
	return (tok_buf *) newSV(0);
}

static void _Tokenizer_tokb_clear(pTHX_ tok_buf *buf)
{
	sv_setpv((SV *)buf, "");
	return;
}

static void _Tokenizer_tokb_put(pTHX_ tok_buf *buf, char *str, unsigned int len)
{
	sv_catpvn((SV *) buf, str, len);
	return;
}

static void _Tokenizer_tokb_del(pTHX_ tok_buf *buf)
{
	sv_2mortal((SV *) buf);
	return;
}

static void _Tokenizer_tokb_init(pTHX)
{
	struct tok_buffer *tb	= (struct tok_buffer *) safemalloc(sizeof(struct tok_buffer));

	tb->ts_new	= (void *)_Tokenizer_tokb_new;
	tb->ts_clear	= (void *)_Tokenizer_tokb_clear;
	tb->ts_put	= (void *)_Tokenizer_tokb_put;
	tb->ts_del	= (void *)_Tokenizer_tokb_del;
#ifdef aTHX
	tb->ts_context	= aTHX;
#else
	tb->ts_context	= NULL;
#endif
	tokenizer_setcb(tb);
	return;
}


MODULE = Text::Tokenizer		PACKAGE = Text::Tokenizer

INCLUDE: const-xs.inc

PROTOTYPES: DISABLE

BOOT:
	_Tokenizer_tokb_init(aTHX);


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
