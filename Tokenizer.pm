package Text::Tokenizer;

use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Tokenizer ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
	TOK_UNDEF TOK_TEXT TOK_DQUOTE TOK_SQUOTE TOK_IQUOTE
	TOK_SIQUOTE TOK_BLANK TOK_ERROR TOK_EOL TOK_COMMENT TOK_EOF
	NOERR UNCLOSED_DQUOTE UNCLOSED_SQUOTE UNCLOSED_IQUOTE NOCONTEXT
	TOK_OPT_DEFAULT TOK_OPT_NONE TOK_OPT_NOUNESCAPE
	TOK_OPT_SIQUOTE TOK_OPT_UNESCAPE TOK_OPT_UNESCAPE_CHARS
	TOK_OPT_UNESCAPE_LINES TOK_OPT_PASSCOMMENT
	tokenizer_options
	tokenizer_new
	tokenizer_new_strbuf
	tokenizer_scan
	tokenizer_exists
	tokenizer_switch
	tokenizer_delete
	tokenizer_flush
	tokenizer_destroy
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
	TOK_UNDEF TOK_TEXT TOK_DQUOTE TOK_SQUOTE TOK_IQUOTE
	TOK_SIQUOTE TOK_BLANK TOK_ERROR TOK_EOL TOK_COMMENT TOK_EOF
	NOERR UNCLOSED_DQUOTE UNCLOSED_SQUOTE UNCLOSED_IQUOTE NOCONTEXT
	TOK_OPT_DEFAULT TOK_OPT_NONE TOK_OPT_NOUNESCAPE
	TOK_OPT_SIQUOTE TOK_OPT_UNESCAPE TOK_OPT_UNESCAPE_CHARS
	TOK_OPT_UNESCAPE_LINES TOK_OPT_PASSCOMMENT
	tokenizer_options
	tokenizer_new
	tokenizer_new_strbuf
	tokenizer_scan
	tokenizer_exists
	tokenizer_switch
	tokenizer_delete
	tokenizer_flush
	tokenizer_destroy
);

our $VERSION = '0.2.6';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Tokenizer::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Text::Tokenizer', $VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Text::Tokenizer - Perl extension for tokenizing text(config) files

=head1 SYNOPSIS

  use Text::Tokenizer ':all';

  #open file and set add it to tokenizer inputs
  open(F_CONFIG, "input.conf");	
  $tok_id	= tokenizer_new(F_CONFIG);
  tokenizer_options(TOK_OPT_NOUNESCAPE|TOK_OPT_PASSCOMMENT);

  while(1)
  {
	($string, $tok_type, $line, $err, $errline)	= tokenizer_scan();
	last if($tok == TOK_ERROR || $tok == TOK_EOF);

	if($tok == TOK_TEXT)		{ 	}
	elsif($tok == TOK_BLANK)	{ 	}
	elsif($tok == TOK_DQUOTE)	{ $str	= "\"$str\"";	}
	elsif($tok == TOK_SQUOTE)	{ $str	= "\'$str\'";	}
	elsif($tok == TOK_SIQUOTE)	{ $str	= "\`$str\'";	}
	elsif($tok == TOK_IQUOTE)	{ $str	= "\`$str\`";	}
	elsif($tok == TOK_EOL)		{	}
	elsif($tok == TOK_COMMENT)	{	}
	elsif($tok == TOK_UNDEF)
		{ last;		}
	else	{ last;	};
	print $str;
  }
  tokenizer_delete($tokid);


=head1 DESCRIPTION

B<Text::Tokenizer> is I<very fast> lexical analyzer, that can be used to process input text
from file or buffer to basic I<tokens>:

=over 4

=item	* NORMAL TEXT

=item	* DOUBLE QUOTED "TEXT"

=item	* SINGLE QUOTED 'TEXT'

=item	* INVERSE QUOTED 'TEXT'

=item	* SINGLE-INVERSE QUOTED `TEXT'

=item	* WHITESPACE TEXT

=item	* #COMMENTS

=item	* END OF LINE

=item	* END OF FILE

=back

=head1 EXPORT

None by default. You have to selectively import methods or constants or use ':all'
to import all constants & methods.

=head1 CONSTANTS

=over 17

=head2 I<TOKEN TYPES> Token types that tokenizer returns.

=item	B<TOK_UNDEF>

Undefined token (tokenizer error)

=item	B<TOK_TEXT>

Normal_text

=item	B<TOK_DQUOTE>

"Double quoted text"

=item	B<TOK_SQUOTE>

'Single quoted text'

=item	B<TOK_IQUOTE>

`Inverse quoted text`

=item	B<TOK_SIQUOTE>

`Single-inverse quoted text'

=item	B<TOK_BLANK>

Whitespace text

=item	B<TOK_COMMENT>

#Comment

=item	B<TOK_EOL>

End of Line

=item	B<TOK_EOF>

End of File

=item	B<TOK_ERROR>

Error Condition (see C<ERROR_TYPES>)


=head2 I<ERROR TYPES> Error codes that will tokenizer return if error happens.

=item	B<NOERR>

No error

=item	B<UNCLOSED_DQUOTE>

Unclosed double quote found

=item	B<UNCLOSED_SQUOTE>

Unclosed single quote found
	
=item	B<UNCLOSED_IQUOTE>

Unclosed inverse quote found

=item	B<NOCONTEXT>

Failed to allocate tokenizer context (FATAL ERROR)


=head2 I<TOKENIZER OPTIONS> Options configurable for tokenizer. They should be OR-ed when passing to tokenizer_options.

=item	B<TOK_OPT_DEFAULT>

Default options set, equals to TOK_OPT_NOUNESCAPE

=item	B<TOK_OPT_NONE>

Set no options. Tokenizer will do in it's default behaviour - it will not unescape anything
and it will not pass comments to you.
	
=item	B<TOK_OPT_NOUNESCAPE>

Disable characters & lines unescaping.

=item	B<TOK_OPT_SIQUOTE>

Enable looking for `single-inverse quote' combination.

=item	B<TOK_OPT_UNESCAPE>

Unescape chars & lines.

=item	B<TOK_OPT_UNESCAPE_CHARS>

Unescape chars

=item	B<TOK_OPT_UNESCAPE_LINES>

Unescape lines

=item	B<TOK_OPT_PASSCOMMENT>

Enable comment passing to user routines.


=back



=head1 METHODS

=over 4

=item	B<$options = tokenizer_options(OPTIONS)>

Set tokenizer options.

=item	B<$tok_id = tokenizer_new(FILE_HANDLE)>

Create new tokenizer instance(context) from FILE_HANDLE identified by B<$tok_id>.

=item	B<$tok_id = tokenizer_new_strbuf(BUFFER, LENGTH)>

Create new tokenizer instance from string BUFFER long LENGTH characters. Return its
tokenizer instance id.

=item	B<@tok = tokenizer_scan()>

Scan current tokenizer instance, and return first token found.
	@tok	= ($string, $type, $line, $error, $error_line)

=over 10
=over 10

=item	$string		- found token string

=item	$type		- it's type

=item	$line		- current line

=item	$error		- equals error code if error occurs

=item	$error_line	- line number where error begins (unclosed quote position)

=back
=back
	
=item	B<tokenizer_exists(TOK_ID)>

Test if tokenizer instance exists.

=item	B<tokenizer_switch(TOK_ID)>

Switch to another tokenizer instance (like when you perform include statment).

=item	B<tokenizer_delete(TOK_ID)>

Delete tokenizer instance (You have to do it exactly on EOF to release connection
between file or buffer.

=item	B<tokenizer_flush(TOK_ID)>

Flush tokenizer instance. This  function  discards  the  instance buffer's  contents, so the 
next time the scanner attempts to match a token from the buffer, it will have to fill it.

=back

=head1 SEE ALSO

This tokenizer is based on code generated by B<flex> - fast lexical analyzer generator 
(http://lex.sourceforge.net).

=head1 AUTHOR

Samuel Behan, E<lt>sam(at)frida.fri.utc.skE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003-2004 by Samuel Behan

This library is free software; you can redistribute it and/or modify
it under the same terms of GNU/GPL v2. 

=cut
