package modules::search::mysql;

use Dancer ':syntax';
use Dancer::Plugin::Database;
use Lingua::Stem::Any;
use HTML::Restrict;
use Encode;
use HTML::Entities;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::search::mysql";
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
	my $text_preview = substr($stext, 0, $preview_length);    
    $text_preview = decode_entities($text_preview);
    $stitle = decode_entities($stitle);
    $stext = decode_entities($stext);
    my $hs = HTML::Restrict->new();
    $text_preview = $hs->process( $text_preview );
	my $data = $stitle.' '.$stext;
    $data = $hs->process( $data );    
    $data =~ s/[^\wА-Яа-яёЁ\s\-]//gm;
    $data =~ s/[\n\r\t]/ /gm;
    $data =~ s/ +/ /gm;    
    $data = lc($data);
    $text_preview =~ s/[\n\r\t]/ /gm;
    $text_preview =~ s/ +/ /gm;            
    $stext = $hs->process( $stext );    
    $stext =~ s/[^\wА-Яа-яёЁ\s\-]//gm;
    $stext =~ s/[\n\r\t]/ /gm;
    $stext =~ s/ +/ /gm;
    if (length($text_preview) < length($stext)) {
    	$text_preview.='...';
    }
    database->quick_delete(config->{db_table_prefix}.'_search_db', { ref_id => $sid, module_id => $mid });
    my $words = join(' ', uniq(split(/ /, $data)));
    my $sth = database->prepare(
   		'INSERT INTO '.config->{db_table_prefix}.'_search_db (slang, stitle, stext, swords, surl, ref_id, module_id, lastchanged) VALUES ('.database->quote($slang).','.database->quote($stitle).','.database->quote($text_preview).','.database->quote($words).','.database->quote($surl).', '.database->quote($sid).', '.database->quote($mid).', '.time.')'
  	);
  	$sth->execute();
  	$sth->finish(); 
}

sub removeFromSearchIndex {    
    my $self=shift;
    my $preview_length = 200;
    my $slang = $_[0];
    my $surl = $_[1];
    my $module_id = $_[1];
    database->quick_delete(config->{db_table_prefix}.'_search_db', { slang => $slang, surl => $surl, module_id => $module_id });
}

sub performSearch {
    my $self=shift;
    my %res;
	my $sstring = $_[0];
    my $slang = $_[1];
    my $page = $_[2];
    my $ipp = $_[3];
    my @all_words = split(/ /, $sstring);
    my $sql_query = '';
    my $stemmer = Lingua::Stem::Any->new(language => $slang);
    foreach my $word (@all_words) {
        my $sw = $stemmer->stem($word);
        if ($sw && $sw ne $word) {
            $sql_query .= ' OR MATCH (swords) AGAINST ('.database->quote($sw.'*').' IN BOOLEAN MODE)';
        }
        $sql_query .= ' OR MATCH (swords) AGAINST ('.database->quote($word).' IN BOOLEAN MODE) OR MATCH (swords) AGAINST ('.database->quote($word.'*').' IN BOOLEAN MODE)';
    }
    $sql_query =~ s/ OR //;
    my $sth = database->prepare(
        'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_search_db WHERE ('.$sql_query.') AND slang='.database->quote($slang)
    );    
    my $total = 0;
    if ($sth->execute()) {
        ($total) = $sth -> fetchrow_array;
    } 
    $sth->finish();
    $res{count} = $total;
    my $limx = $page*$ipp-$ipp;
    if ($total) {
        my $sth = database->prepare(
            'SELECT stitle, stext, surl FROM '.config->{db_table_prefix}.'_search_db WHERE ('.$sql_query.') AND slang='.database->quote($slang).' LIMIT '.$limx.', '.$ipp
        );        
        my @res_arr;
        if ($sth->execute()) {
            while (my ($stitle,$stext,$surl) = $sth->fetchrow_array) {
                my %item;
                $item{'title'} = $stitle;
                $item{'text'} = $stext;                
                $item{'url'} = $surl;
                push @res_arr, \%item;
            }
        }
        $res{items} = \@res_arr;
        $sth->finish();
    }
    return \%res;
}

# Helper functions

sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

# End

1;