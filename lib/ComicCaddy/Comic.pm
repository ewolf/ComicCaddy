package ComicCaddy::Comic;

use base 'Yote::Obj';

sub update {
    my( $self, $data, $account ) = @_;
    $self->_update( $data, qw/name url description/);
}

1;

__END__
