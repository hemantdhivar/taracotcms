package taracot::typo;
use Dancer ':syntax';
use Encode;
use Lingua::Identify qw(:language_identification);
use taracot::jevix;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "taracot::typo";
 return $self;
}

sub process {
	my $self = shift;
	my $_text = $_[0];
  my $_force = $_[1];
	if (langof($_text) ne 'ru' && !$_force) {
		return $_text;
	}
	my $conf = {
      isHTML => 1, # Hypertext mode (plain text mode is faster)
      vanish => 0, # Convert source into plain text (ignores all other options)
      lineBreaks => 0, # Add linebreaks <br />
      paragraphs => 0, # Add paragraphs <p>
      dashes => 1, # Long dashes
      dots => 1, # Convert three dots into ellipsis
      edgeSpaces => 1, # Clear white spaces around string
      tagSpaces => 1, # Clear white spaces between tags (</td> <td>)
      multiSpaces => 1, # Convert multiple white spaces into single
      redundantSpaces => 1, # Clear white spaces where they should not be
      compositeWords => 1, # Put composite words inside <nobr> tag
      compositeWordsLength => 10, # The maximum length of composite word to put inside <nobr>
      nbsp => 1, # Convert spaceses into non-breaking spaces where necessary
      quotes => 1, # Quotes makeup
      qaType => 0, # Outer quotes type (http://jevix.ru/)
      qbType => 1, # Inner quotes type
      misc => 0, # Little things (&copy, fractions and other)
      codeMode => 2, # Special chars representation (0: ANSI <...>, 1: HTML <&#133;>, 2: HTML entities <&hellip;>)
      tagsDenyAll => 0, # Deny all tags by default
      tagsDeny => '', # Deny tags list
      tagsAllow => '', # Allowed tags list (exception to "deny all" mode)
      tagCloseSingle => 0, # Close single tags when they are not
      tagCloseOpen => 1, # Close all open tags at the end of the document
      tagNamesToLower => 1, # Bring tag names to lower case
      tagNamesToUpper => 0, # Bring tag names to upper case
      tagAttributesToLower => 1, # Bring tag attributes names to lower case
      tagAttributesToUpper => 0, # Bring tag attributes names to upper case
      tagQuoteValues => 1, # Quote tag attribute values
      tagUnQuoteValues => 0, # Unquote tag attributes values
      links => 0, # Put urls into <a> tag
      linksAttributes => {target=>'_blank'}, # Hash containing all new links attributes set
      simpleXSS => 0, # Detect and prevent XSS
      checkHTML => 1, # Check for HTML integrity
      logErrors => 0 # Log errors
    };
    my $jevix = new taracot::jevix;
    $jevix->setConf($conf);
    my $text = decode_utf8($jevix->process(\encode_utf8($_text))->{text});
    return $text;
}

# End

1; 