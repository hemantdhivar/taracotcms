#!/usr/bin/perl
use Dancer ':script'; 
use Lucy::Index::Indexer;
use Lucy::Plan::Schema;
use Lucy::Analysis::PolyAnalyzer;
use Lucy::Plan::FullTextType;
use Cwd 'abs_path';
use taracot::fs;

my $path = dirname(abs_path($0)) || '';
$path =~ s/bin$//;
Dancer::Config::setting('appdir', $path);
Dancer::Config::load();

my @langs = split(/,/, config->{lang_available});
foreach my $slang (@langs) {
	$slang =~ s/ //gm; 
	my $schema = Lucy::Plan::Schema->new;
	my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
		language => $slang,
	);
	my $fulltext_type = Lucy::Plan::FullTextType->new(
		analyzer => $polyanalyzer,
	);
	my $string_type = Lucy::Plan::StringType->new();
	my $int_type = Lucy::Plan::Int32Type->new();
	$schema->spec_field( name => 'title', type => $fulltext_type );
	$schema->spec_field( name => 'text', type => $fulltext_type );
	$schema->spec_field( name => 'module', type => $string_type );
	$schema->spec_field( name => 'url', type => $string_type );
	$schema->spec_field( name => 'id', type => $string_type );
	$schema->spec_field( name => 'lang', type => $string_type );
	makePath(config->{root_dir}.'/'.config->{data_dir}.'/search_index/'.$slang);
	my $indexer = Lucy::Index::Indexer->new(
		schema => $schema,
		index  => config->{root_dir}.'/'.config->{data_dir}.'/search_index/'.$slang,
		create => 1,
	);
}