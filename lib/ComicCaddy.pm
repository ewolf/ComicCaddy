package ComicCaddy;

#
# This app keeps track of comics that you read and alerts you when there are updates to the comics.
#

use strict;

use Yote::Util::Tag;

use base 'Yote::AppRoot';

use Digest::MD5 qw/md5_hex/;
use HTTP::Request;
use LWP::UserAgent;

sub _init {
    my $self = shift;
    $self->set__comic_tags( Yote::Util::Tag->new() );
    $self->set__comics({});
} #_init

sub _init_account {
    my( $self, $acct ) = @_;
    $acct->set_my_comics({});
    $acct->set_caddy( $self );
} #_init_account

sub _link_md5 {
    my( $url ) = @_;
    if( $url !~ /^http/ ) {
	$url = "http://$url";
    }
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    my $resp = $ua->get( $url );
    if( $resp->is_success ) {
	return md5_hex( $resp->decoded_content );
    }
    return '';
} # _link_md5

sub _check_link {
    my( $url ) = @_;
    if( $url !~ /^http/ ) {
	$url = "http://$url";
    }
    my $req = HTTP::Request->new( HEAD => $url );
    my $ua = new LWP::UserAgent;
    $ua->timeout(10);
    $ua->env_proxy;
    my $res = $ua->request( $req, sub { die }, 1 );
    return $res->is_success;
} # _check_link


# sub _url_to_xpath {
#     my( $self, $url ) = @_;
#     $url =~ s!https?://!!;
#     $url =~ s!/$!!;

#     $url =~ s/\//\\\//g; #convert to use as a single xpath part
#     return $self->_path_to_root() . "/_comics/$url";
# } #_url_to_xpath

sub search {
    my( $self, $str, 
} #search

#
# take things apart gru wise with names.
# zebra girl would match z, ze, zeb, zebr, zebra --> zebra token
#                        ( level one gru )  ===> token ---> ( token as level two gru input )
#    In that model, even common spelling errors could be caught with the following training
#       user inputs zebar rather than zebra, but picks zebra from the list. 
#
# Still no closer to categorization
#

1;

__END__

# sub Search {
    
# } #Search

# sub add_link {
    
# } #add_link

# sub comic {
#     my( $self, $url, $acct ) = @_;
#     return Yote::ObjProvider::xpath( $self->_url_to_xpath( $url ) );
# } #comic

# sub add_comic {
#     my( $self, $data, $acct ) = @_;
    
#     if( ref( $data ) ne 'HASH' ) {
# 	die "add_comic takes a hash as an argument";
#     }
#     if( ! $data->{url} ) {
# 	die "url needed for add_comic";
#     }

#     my $xpath = $self->_url_to_xpath( $data->{url} );

#     if( Yote::ObjProvider::xpath_count( $xpath ) ) {
# 	return "Comic already submitted";
#     }

#     my $md5 = $self->_link_md5( $hash_url );
#     if( ! $md5 ) {
# 	die "Unable to find link";
#     }

#     my $comic = new Yote::Obj( $data );

#     Yote::ObjProvider::xpath_insert( $xpath, $comic );

#     $comic->set_added_by( $acct );
#     $comic->set_added_on( time() );
#     $comic->set_last_updated( time() );
#     $comic->set_md5( $md5 );

#     $self->follow_comic( $comic, $acct );
    
#     return $comic;
# } #add_comic

# sub is_following_comic {
#     my( $self, $data, $acct ) = @_;
#     my $comics = $acct->get_my_comics({});
#     return ref( $comics->{ $data->{ID} } );
# } #is_following_comic

# # ---------- methods that deal with the account directly ------------

# sub read_comic {
#     my( $self, $data, $acct ) = @_;
#     my $node = $self->get_my_comics({})->{ $data->{ID} };
#     if( $node ) {
# 	$node->set_last_seen( time() );
# 	$node->set_last_md5( $node->get_comic()->get_last_md5() );
#     }
# } #read_comic

# sub remove_comic {
#     my( $self, $data, $acct ) = @_;
#     my $comic = $data;
#     my $comics = $acct->get_my_comics({});
#     delete $comics->{ $comic->{ID} };
# } #remove_comic

# sub follow_comic {
#     my( $self, $data, $acct ) = @_;
#     my $root_path = $acct->_path_to_root();
#     if( 0 == Yote::ObjProvider::xpath_count( "$root_path/_my_comics/$data->{ID}" ) ) {
# 	my $comic_node = new Yote::Obj( { comic => $data, followed_on => time(), last_read => 0 } );
# 	$comic_node->set_last_seen( time() );
# 	my $md5 = $comic_node->get_comic()->get_last_md5();
# 	$comic_node->set_last_md5( $md5 );
# 	Yote::ObjProvider::xpath_insert( "$root_path/_my_comics/$data->{ID}", $comic_node );
#     }
# } #follow_comic

# sub my_comic_nodes {
#     my( $self, $data, $acct ) = @_;
#     my $comics = $acct->get_my_comics({});
#     for my $comic_node (values %$comics) {
# 	my $comic = $comic_node->get_comic();
# 	# if the comic had not been updated in last 24 hours, give a check
# 	if( time() - $comic->set_last_updated() > 24 * 3600 ) {
# 	    # move this to a cron eventually though
# 	    $comic->set_md5( $self->_link_md5( $comic->get_url() ) );
# 	    $comic->set_last_updated( time() );
# 	}
# 	$comic_node->set_has_update( $comic_node->get_last_md5() ne $comic->get_last_md5() );
#     }
#     return [values %$comics];
# } #my_comic_nodes
