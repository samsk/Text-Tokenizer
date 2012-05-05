#copy-mode test
#

use strict;
use Test::More tests => 10;
BEGIN { use_ok('Text::Tokenizer') };

my($tokid, $fh, $strbuf);

# read file
ok(open($fh, $0),	'open() call');
while(my $l = <$fh>)
{	$strbuf .= $l;	}

# stat data
my (@sti);
@sti	= stat($fh);
close($fh);

#create tokenizer
ok(($tokid = tokenizer_new_strbuf($strbuf, length($strbuf))), 'Tokenizer create from string');
ok(tokenizer_exists($tokid), 'Tokenizer exists');
ok(tokenizer_switch($tokid), 'Tokenizer switch');
ok(tokenizer_options(TOK_OPT_NOUNESCAPE|TOK_OPT_PASSCOMMENT), 'Tokenizer options');

#get size of file via tokenizer
my ($str, $tok, $lin, $err, $errlin, $file_len);
$file_len	= 0;
my $go		= 1;

while($go == 1)
{
	($str, $tok, $lin, $err, $errlin)	= tokenizer_scan();
	last if($tok == TOK_ERROR || $tok == TOK_EOF);

	if($tok == TOK_TEXT)		{ 	}
	elsif($tok == TOK_BLANK)	{ 	}
	elsif($tok == TOK_DQUOTE)	{ $str	= "\"$str\"";	}
	elsif($tok == TOK_SQUOTE)	{ $str	= "\'$str\'";	}
	elsif($tok == TOK_SIQUOTE)	{ $str	= "\`$str\'";	}
	elsif($tok == TOK_IQUOTE)	{ $str	= "\`$str\`";	}
	elsif($tok == TOK_EOL)		{	}
	elsif($tok == TOK_COMMENT)	{ $str  = '#'.$str;	}
	elsif($tok == TOK_UNDEF)
		{ last;		}
	else	{ last;	};

	#print STDERR $str;
	$file_len	+= length($str);
}
ok( $tok == TOK_EOF,		'File read');

ok(tokenizer_delete($tokid),	'Tokenizer delete');

#stat file size
ok( defined($sti[7]), 'stat() call');
ok( $file_len == $sti[7] , 'Size compare' );

__END__

SOME TEST CASES:

//wsdasd
/*sfd
ad
asd
*/ /* adasd */
