package modules::search::mysql;

use utf8;
use Encode;
use HTML::Strip;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Lingua::Stem::Any;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::search::plugin_mysql";
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
	$stext=~s/&nbsp;/ /gm;
	my $text_preview = substr($stext, 0, $preview_length);
	my $data = $stitle.' '.$stext;		
    my $hs = HTML::Strip->new();
    $data = decode_utf8($hs->parse( $data ));
    $hs->eof;
    $text_preview = decode_utf8($hs->parse( $text_preview ));
    $hs->eof;
    $data =~ s/[^\wА-Яа-яёЁ\s\-]//gm;
    $data =~ s/[\n\r]/ /gm;
    $data =~ s/ +/ /gm;    
    $data = lc($data);
    $text_preview =~ s/[^\wА-Яа-яёЁ\s\-,\.;:]//gm;
    $text_preview =~ s/[\n\r]/ /gm;
    $text_preview =~ s/ +/ /gm;        
    if (length($text_preview) < $preview_length) {
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
    $res{sql} = 'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_search_db WHERE ('.$sql_query.') AND slang='.database->quote($slang);
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