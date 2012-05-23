package taracot::loadpm;

# Based on Module::Load by Jos Boumans <kane@cpan.org>

$VERSION = '0.18';

use strict;
use File::Spec ();

sub import {
    my $who = _who();

    {   no strict 'refs';
        *{"${who}::loadpm"} = *loadpm;
    }
}

sub loadpm (*;@)  {
    my $mod = shift or return;
    my $who = _who();

    if( _is_file( $mod ) ) {
        require $mod;
    } else {
        LOAD: {
            my $err;
            for my $flag ( qw[1 0] ) {
                my $file = _to_file( $mod, $flag);
                eval { require $file };
                $@ ? $err .= $@ : last LOAD;
            }
            die $err if $err;
        }
    }
    {   no strict 'refs';
        my $import;
        if (@_ and $import = $mod->can('import')) {
            unshift @_, $mod;
            goto &$import;
        }
    }
}

sub _to_file{
    local $_    = shift;
    my $pm      = shift || '';
    my @parts = split /::/;
    my $file = $^O eq 'MSWin32'
                    ? join "/", @parts
                    : File::Spec->catfile( @parts );
    $file   .= '.pm' if $pm;
    $file = VMS::Filespec::unixify($file) if $^O eq 'VMS';

    return $file;
}

sub _who { (caller(1))[0] }

sub _is_file {
    local $_ = shift;
    return  /^\./               ? 1 :
            /[^\w:']/           ? 1 :
            undef
}


1;

__END__
