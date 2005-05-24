use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Text::Tokenizer',
    VERSION_FROM      => 'Tokenizer.pm', # finds $VERSION
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'Tokenizer.pm', # retrieve abstract from module
       AUTHOR         => 'Sam <sam(at)frida.fri.utc.sk>') : ()),
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '-DHAVE_CONFIG_H -DHAVE_CALLBACK_BUFFER', 
    INC               => '-I.', 
    OBJECT            => q[Tokenizer$(OBJ_EXT) lex.tokenizer_yy$(OBJ_EXT)], # link all the C files too
);

####
# Inport constants
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw(TOK_UNDEF TOK_TEXT TOK_DQUOTE TOK_SQUOTE TOK_IQUOTE
		TOK_SIQUOTE TOK_BLANK TOK_ERROR TOK_EOL TOK_COMMENT TOK_EOF
		NOERR UNCLOSED_DQUOTE UNCLOSED_SQUOTE UNCLOSED_IQUOTE NOCONTEXT
		TOK_OPT_DEFAULT TOK_OPT_NONE TOK_OPT_NOUNESCAPE
	        TOK_OPT_SIQUOTE TOK_OPT_UNESCAPE TOK_OPT_UNESCAPE_CHARS
		TOK_OPT_UNESCAPE_LINES TOK_OPT_PASSCOMMENT));
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Tokenizer',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
