package ComicCaddy;

#
# This app keeps track of comics that you read and alerts you when there are updates to the comics.
#

use strict;

use ComicCaddy::Comic;

use Yote::Util::Tag;

use base 'Yote::AppRoot';

use Digest::MD5 qw/md5_hex/;
use HTTP::Request;
use LWP::UserAgent;

sub _init {
    my $self = shift;
    $self->set__comic_tags( Yote::Util::Tag->new() );
    $self->set__comics([]);
} #_init

sub _init_account {
    my( $self, $acct ) = @_;
    $acct->set_my_comics([]);
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


sub new_comic {
    my( $self, $data, $acct ) = @_;
    die "Must be logged in to add comic" unless $acct;
    my $newcomic = new ComicCaddy::Comic( $data );
    $self->add_to__comics( $newcomic );
    return $newcomic;
} #new_comic

sub remove_comic {
    my( $self, $data, $acct ) = @_;
    die "Must be logged in to remove comic" unless $acct;
    $self->remove_from__comics( $data );
} #remove_comic

sub search_list {
    my( $self, $data, $acct ) = @_;
    my( $list_name, $search_fields, $search_terms, $amount, $start ) = @$data;
    # list_name and search fields are already known
    my %allowed_fields = map { $_ => 1; } ( 'url', 'name', 'description' );
    $search_fields = $search_fields ? [ grep { $allowed_fields{$_} } @$search_fields ] : [keys %allowed_fields];
    return Yote::ObjProvider::search_list( $self->{DATA}{ _comics }, $search_fields, $search_terms, $amount || 10, $start );
} #search_list

sub paginate_list {
    my( $self, $data, $account ) = @_;
    
    my( $list_name, $number, $start ) = @$data;
    return Yote::ObjProvider::paginate_list( $self->{DATA}{$list_name}, $number, $start );

} #paginate_list

sub is_admin {
    my( $self, $data, $account ) = @_;

    return $account->get_login()->is_root() || $account->get__is_admin();
} #is_admin

sub make_admin {
    my( $self, $data, $account ) = @_;
    die "Permissions Error" unless $self->is_admin( $account );
    $data->set__is_admin();
} #make_admin



sub count {
    my( $self, $data, $account ) = @_;
    return $self->_count( $data );
} #count


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

