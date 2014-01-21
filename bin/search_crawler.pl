#!/usr/bin/perl
# Search module crawler

# Check configuration variabled below

use strict;
use warnings;
use DBI;
use Dancer ':script';
use Dancer::Plugin::Database;
use Cwd 'abs_path';
use taracot::fs;

my $crawler_path = dirname(abs_path($0)) || '';
$crawler_path =~ s/bin$//;
Dancer::Config::setting('appdir', $crawler_path);
Dancer::Config::load();

# Do not edit below this line, if you're not sure what you're doing
# Configuration ends here

my $dbh;
my $sth;
require 'modules/search/'.config->{search_plugin}.'.pm';
my $sp = 'modules::search::'.config->{search_plugin};
my $search_plugin = "$sp"->new(); 

sub connect_db {
	my $DSN = 'DBI:mysql:'.config->{plugins}->{Database}->{database}.':'.config->{plugins}->{Database}->{host};
	$dbh = DBI->connect($DSN, config->{plugins}->{Database}->{username}, config->{plugins}->{Database}->{password});
	my $sth = $dbh->prepare("SET NAMES 'utf8'");
 	$sth->execute();
 	$sth->finish();
	$sth = $dbh->prepare("SET CHARACTER SET 'utf8'");
	$sth->execute();
	$sth->finish();
}

sub disconnect_db {
	$dbh->disconnect();
	$dbh = undef;
}

# Connect to DB
&connect_db();

# Emtpy search database

$sth = database->prepare('DELETE FROM '.config->{db_table_prefix}.'_search_db WHERE 1');
$sth->execute();
$sth->finish(); 

# BEGIN: Crawl data for module: pages

$sth = database->prepare('SELECT id, pagetitle, content, filename, lang FROM '.config->{db_table_prefix}.'_pages WHERE status = 1');
if ($sth->execute()) {
	while(my ($id, $pagetitle, $content, $filename, $lang) = $sth -> fetchrow_array) {
 		$search_plugin->updateSearchIndex($lang, $pagetitle, $content, $filename, $id, 'pages');
	}
}
$sth->finish();

# END: Crawl data for module: pages

# BEGIN: Crawl data for module: blog

$sth = database->prepare('SELECT id, ptitle, ptext_html, plang FROM '.config->{db_table_prefix}.'_blog_posts WHERE pstate=1 AND mod_require=0 AND deleted=0');
if ($sth->execute()) {
	while(my ($id, $ptitle, $ptext_html, $plang) = $sth -> fetchrow_array) {
 		$search_plugin->updateSearchIndex($plang, $ptitle, $ptext_html, '/blog/post/'.$id, $id, 'blog');
	}
}
$sth->finish();

# END: Crawl data for module: pages

# BEGIN: Crawl data for module: portfolio

my $portfolio_id = 0;
my @langs = split(/,/, config->{lang_available});
foreach my $lng (@langs) {
	$lng =~ s/ //gm;
	my $lf = loadFile(config->{root_dir}.'/'.config->{portfolio_path}.'/portfolio_'.$lng.'.json');
	if (!$lf) {
		print "WARNING: Can't load ".config->{root_dir}.'/'.config->{portfolio_path}.'/portfolio_'.$lng.'.json, skipping'."\n";
	} else {
		my $pf=from_json $$lf;
		foreach my $item (@{ $pf->{data} }) {  
		  my $works = $item->{works};
		  foreach my $key (keys %{ $works }) {
			my $lf = loadFile(config->{root_dir}.'/'.config->{portfolio_path}.'/'.$key.'_'.$lng.'.json');
			if (!$lf) {
				print "WARNING: Can't load ".config->{root_dir}.'/'.config->{portfolio_path}.'/'.$key.'_'.$lng.'.json, skipping'."\n";
			} else {
				my $pi=from_json $$lf;
				$portfolio_id++;
				$search_plugin->updateSearchIndex($lng, $pi->{title}, $pi->{comp}, "/portfolio/".$key, $portfolio_id, 'portfolio');
			}
		  }
		}  
	}
}

# END: Crawl data for module: portfolio

# Disconnect from DB
&disconnect_db();