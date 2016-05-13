package PearlPBX::DB;

use warnings;
use strict;

use DBI;
use Config::General;

use Exporter;
our @EXPORT_OK = qw(pearlpbx_db);

my $this;

sub pearlpbx_db {
  return $this;
}

sub new {
  my ($class, $conf) = @_;

  unless ( $this ) {
    $conf //= "pearlpbx.conf";
    my $config = Config::General->new (
      -ConfigFile        => $conf,
      -AllowMultiOptions => 'yes',
      -UseApacheInclude  => 'yes',
      -InterPolateVars   => 'yes',
      -ConfigPath        => [ $ENV{PEARL_CONF_DIR}, '/etc/PearlPBX' ],
      -IncludeRelative   => 'yes',
      -IncludeGlob       => 'yes',
      -UTF8              => 'yes',
    );

    unless ( ref $config ) {
      die "Can't read config.";
    }

    my %cf_hash = $config->getall or ();
    $this = bless {
      conf => \%cf_hash,
      dbh  => undef
    }, $class;

    $this->_connect();

  }

  return $this;
}

sub _connect {
  my $this = shift;

  my $dsn  = $this->{conf}->{db}->{main}->{dsn} // 'dsn dbi:Pg:dbname=asterisk;host=127.0.0.1';
  my $user = $this->{conf}->{db}->{main}->{login} // 'asterisk';
  my $pass = $this->{conf}->{db}->{main}->{password} // 'supersecret';

  if ( !$this->{dbh} or !$this->{dbh}->ping ) {
    $this->{dbh} = DBI->connect_cached ( $dsn, $user, $pass,
                    { RaiseError => 1, AutoCommit => 1 } );

  }
  if ( !$this->{dbh} ) {
    die "Can't connect to database: " . $dsn;
  }

  return 1;

}

1;

