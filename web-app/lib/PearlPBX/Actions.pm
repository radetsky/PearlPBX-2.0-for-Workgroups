package PearlPBX::Actions;

use warnings;
use strict;

use Data::Dumper;

use Plack::Request;

use PearlPBX::ScalarUtils;
use Pearl::Logger;
use PearlPBX::Notifications;
use Pearl::Const;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (
    action_login
    action_logout
);

sub _webuser_authenticate {
    my ($email, $password) = @_;

    my $crypted = undef;

    eval {
    ($crypted) = $this->{dbh}->selectrow_array("select role, passwd_hash from auth.sysusers where login=".$this->{dbh}->quote($username));
    };

  if ( $@ ) {
    warn $this->{dbh}->errstr;
    return undef;
  }

  if (defined $crypted) {
    $crypted =~ s/\s+//gs;
    if (crypt($password,$crypted) eq $crypted) {
      $this->{userid} = $username;
      $this->_loadProfile($this->{userid});
      return 1;
    }
  }


}

sub action_login {

    my $env     = shift;
    my $req     = Plack::Request->new($env);
    my $session = $req->session;
    my $params  = $req->parameters;

    my $email    = trim( $params->{log_username} // '' );
    my $password = trim( $params->{log_password} // '' );

    my $user = _webuser_authenticate( $email, $password );

    # we waiting for { result = OK | FAIL, [ reason, user_params e.g. role, sip_name, etc. ]}
    if ( !defined($user) || !defined( $user->{result} ) ) {
        # Something goes wrong
        MessageBox( $env, MSG_SERVER_ERROR, "error" );
        return page_login($env);
    }
    elsif ( $user->{result} ne OK ) {
        MessageBox( $env, $user->{reason}, "error" );
        return page_login($env);
    }
    else {
        $session->{'account'}     = $email;
        $session->{'user_params'} = $user->{user_params};
        my $res = $req->new_response( 302, [ 'Location' => '/' ] );
        $res->body('Authenticated');
        return $res->finalize($env);
    }
    MessageBox ($env, MSG_SERVER_ERROR, "error");
    Err(MSG_SERVER_ERROR);
    return page_login($env);
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

