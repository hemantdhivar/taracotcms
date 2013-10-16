#!/usr/bin/perl
open(DATA, "admin_pages_index.tt");
my $data = join ('', <DATA>);
close(DATA);
my @values = ( $data =~ /\[== ([^ =\]]+) =]/g );
my @values_nd;
my %jsvalues;
my $js;
my %dupes;
foreach my $item (@values) {
	if ($dupes{$item}) {
		next;
	} else {
		$dupes{$item}=1;
		push(@values_nd, $item);
	}
	my $jsitem=$item;
	$jsitem=~s/\$/js_/gm;
	$jsitem=~s/\-\>/_/gm;
	$jsitem=~s/\{//gm;
	$jsitem=~s/\}//gm;
	$jsvalues{$item}=$jsitem;
	$js.=qq~var $jsitem = "[== $item =]";\n~;
	#print "$item\n";
}
my ($crap, $tmp) = split(/\<script type=\"text\/javascript\"\>/, $data);
my ($jscode, $crap2) = split(/\<\/script\>/, $tmp);
foreach my $item (@values_nd) {
	my $ritem=$item;
	$ritem=~s/\$/\\\$/g;
	$ritem=~s/\{/\\\{/g;
	$ritem=~s/\}/\\\}/g;
	$jscode=~s/\"\[== $ritem =\]\"/$jsvalues{$item}/g;
	$jscode=~s/\'\[== $ritem =\]\'/$jsvalues{$item}/g;
	$jscode=~s/\[== $ritem =\]/$jsvalues{$item}/g;
}
print $js;
print $jscode;