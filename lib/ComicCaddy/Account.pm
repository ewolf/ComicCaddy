package ComicCaddy::Account;

use base 'Yote::Account';

sub follow {
    my( $self, $url, $acct ) = @_;

    my $app = $acct->get_caddy();

    my $comic = $app->_hash_fetch( '_comics', $url );
    unless( $comic ) {
	$comic = ComicCaddy::Comic->new();
	$app->_hash_insert( '_comics', $url, $comic );
    }

    my $comics = $acct->get_my_comics();
    my $node = $comics->{ $comic->{ID} };
    unless( $node ) {
	$node = Yote::Obj->new();
	$node->set_comic( $comic );
	$comics->{ $comic->{ID} } = $node;
    }
    return $node;
} #follow

sub unfollow {
    my( $self, $comic_node, $acct ) = @_;
    my $comics = $acct->get_my_comics();
    delete $comics->{ $comic_node->get_comic()->{ ID } };
    return;
} #unfollow

sub bookmark {
    my( $self, $data, $acct ) = @_;
    # lets hold off on this now
} #bookmark
