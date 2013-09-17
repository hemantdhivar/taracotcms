package modules::search::lucy;

use Dancer ':syntax';
use HTML::Restrict;
use Encode;
use taracot::fs;
use HTML::Entities;
use Lucy::Index::Indexer;
use Lucy::Plan::Schema;
use Lucy::Analysis::PolyAnalyzer;
use Lucy::Plan::FullTextType;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::search::lucy";
 return $self;
}

sub updateSearchIndex {    
  my $self=shift;
  my $preview_length = 200;
  my $slang = $_[0];
  my $stitle = decode_utf8($_[1]);
  my $stext = decode_utf8($_[2]);
  my $surl = $_[3];
  my $sid = $_[4];
  my $mid = $_[5];
  $stext =~ s/<h1[^>]*>.*?<\/h1>//is;
  $stext =~ s/<script[^>]*>.*?<\/script>//igs;
  $stitle = decode_entities($stitle);
  $stext = decode_entities($stext);
  my $hs = HTML::Restrict->new();
  my $data = $stext;
  $data = $hs->process( $data );    
  $data =~ s/[\n\r\t]/ /gm;
  $data =~ s/ +/ /gm;
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
   create => 0,
   truncate => 0
  );
  #$indexer->delete_by_term( 'field' => 'id', 'term' => $sid, 'field' => 'module', 'term' => $mid );
  $indexer->delete_by_term( 'field' => 'url', 'term' => $surl );
  print "Adding URL: $surl\n";
  $indexer->add_doc({
   title  => $stitle,
   text => $data,
   url => $surl,
   id => $sid,
   module => $mid,
   lang => $slang
  });
  print "Comitting\n";
  $indexer->commit();
}

sub performSearch {
 my $self=shift;
 my %res;
 my $sstring = $_[0];
 my $slang = $_[1];
 my $page = $_[2];
 my $ipp = $_[3];
 my $total = 0;
 my $searcher = Lucy::Search::IndexSearcher->new( 
  index => config->{root_dir}.'/'.config->{data_dir}.'/search_index/'.$slang,
 );
 my $hits = $searcher->hits(
  query      => $sstring,
  offset     => $page*$ipp-$ipp,
  num_wanted => $ipp,
 );
 my $highlighter = Lucy::Highlight::Highlighter->new(
  searcher => $searcher,
  query    => $sstring,
  field    => 'text',
  excerpt_length => 250
 );
 $highlighter->set_pre_tag('<b>');
 $highlighter->set_post_tag('</b>');
 $res{count} = $hits->total_hits;
 if ($hits->total_hits > 0) {
  my @res_arr;
  while ( my $hit = $hits->next ) {
   my %item;
   $item{'title'} = $hit->{title};
   my $text = $highlighter->create_excerpt($hit);
   #if (length($text) < length($hit->{text})) {
   # $text.='...';
   #}
   $item{'text'} = $text;
   $item{'url'} = $hit->{url};
   push @res_arr, \%item; 
  }
  $res{items} = \@res_arr;
 }
 return \%res;
}

# End

1;
