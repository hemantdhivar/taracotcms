#!/usr/bin/perl
use utf8;
chdir('../../views');
my @files = <*.tt>;
foreach my $file (@files) {
	# Don't minify the e-mail templates
	if ($file=~m/_mail_/) { next; }
	print "Processing $file...\n";
	open (DATA, $file);
	my $tt = join('', <DATA>);
	close(DATA);
	my ($temp, $js) = split(/\<script type=\"text\/javascript\"\>/, $tt);
	($js, $temp) = split(/\<\/script\>/, $js);
	if (!$js) {
		print "Warning: no JS for $file!\n";
	} else {
		# open(DATA, ">$file.js");
		# binmode(DATA);
		# print DATA $js;
		# close(DATA);	
	}
	# workaround 1
	$js=~s/HashTable\(\{\[== \$hash_langs =\]\}\);/HashTable({re: 'place'});/gm;
	open(DATA, ">.temp");
	binmode(DATA);
	print DATA $js;
	close(DATA);
	if ($file =~ m/^admin/) {
			system('type .temp > .ugly');
		} else {
			system('uglifyjs2 .temp --compress > .ugly');	
		}
		
	open (DATA, '.ugly');
	binmode(DATA);
	my $ugly = join('', <DATA>);
	# workaround 1
	$ugly=~s/HashTable\(\{re\: \'place\'\}\);/HashTable({[== $hash_langs =]});/gm;
	close(DATA);
	$tt=~s/\n//gm;
	$tt=~s/\s+/ /g;
	$tt=~s/\> \</></g;
	if ($ugly) {
		$tt =~ s/\<script type=\"text\/javascript\"\>(.*)\<\/script\>/\<script type=\"text\/javascript\"\>$ugly\<\/script\>/gm;
	} else {
		print "Warning: no data for $file!\n";
	}
	open(DATA, '>'.$file);
	binmode(DATA);
	print DATA $tt;
	close(DATA);
}
unlink('.ugly');
unlink('.temp');
print "All done!\n";