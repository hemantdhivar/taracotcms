#!/usr/bin/perl

get_files('./');

sub get_files {
 chdir $_[0];
 my @files = <*>;
 foreach my $file (@files) {
 	if (-d $file) {
 		&get_files($file);
 		chdir('..');
 	}
 	if ($file=~m/\.tt/i) {
 		print "File found: $file\n";
 		open(DATA, $file);
 		binmode(DATA);
		my $data = join('', <DATA>);
		close(DATA);
		$data =~ s/ +/ /gm;
		$data=~s/^\s+//gm;
		$data=~s/\s+$//gm;
		$data=~s/\> \</></gm;
		$data=~s/[\t\n\r]//gm;
		open(DATA, ">$file");
		binmode(DATA);
		print DATA $data;		
		close(DATA);
 	}
 } 
}