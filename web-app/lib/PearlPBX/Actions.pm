package PearlPBX::Actions; 

use warnings;
use strict; 

use Data::Dumper;

use Plack::Request;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (
    action_login
    action_logout
);

sub action_login {

    my $env     = shift;
    my $req     = Plack::Request->new($env);
    my $session = $req->session;
    my $params  = $req->parameters;

    # $params is the hashref to Hash::MultiValue object, but with latest values we can
    # work just like with usual perl hashes and hashrefs

    my $email    = trim($params->{log_username} // '');
    my $password = trim($params->{log_password} // '');
    
    my $fail = 0; 

    if ( $fail > 0 ) {
        return page_login($env);
    }

    my $res = $req->new_response( 302, [ 'Location' => '/' ] );
    $res->body('Authenticated');
    return $res->finalize($env);

}

sub action_logout {
    my $env = shift;
    my $req = Plack::Request->new($env);

    # clear session
    my $session_options = $req->session_options;
    $session_options->{expire} = 1;

    # Redirect to page_login.
    my $res = $req->new_response( 302, [ 'Location' => '/login' ] );
    $res->body('Log Out');
    return $res->finalize();

}

