package Dancer::Template::Taracot;

# Fork of Dancer::Template::Tenjin patched for Windows by Michael Matveev

use strict;
use warnings;

our $VERSION = "0.5";
$VERSION = eval $VERSION;

use Tenjin 0.070001;
use Dancer::Config 'setting';
use File::Basename;
use Try::Tiny;
use Carp;

use base 'Dancer::Template::Abstract';

sub init {
	$_[0]->{engine} = Tenjin->new({ cache => 0, postfix => '.tt', path => [setting('views')] });
}

sub render($$$) {
	my ($self, $template, $tokens) = @_;
	croak "'$template' is not a regular file"
		if !ref $template && !-f $template;
	$tokens ||= {};
	$template=~s/\\/\//gm;
	foreach (@{$self->{engine}->{path}}) {
		my $basepath = $_;
		$basepath=~s/\\/\//gm; 
		$basepath .= '/' unless $basepath =~ m!/^!;
		next unless $template =~ m/^$basepath/;
		$template =~ s/^$basepath//;
	}
	foreach (keys %$tokens) {
		delete $tokens->{$_} if m/[ ()]/;
	}
	my $output = try { $self->{engine}->render($template, $tokens) } catch { croak $_ };
	return $output;
}

1;