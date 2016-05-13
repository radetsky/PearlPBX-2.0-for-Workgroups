#!/usr/bin/env perl 
#===============================================================================
#         FILE:  PearlPBX-gui-passwd.pl
#        USAGE:  ./PearlPBX-gui-passwd.pl <email> <password> <roles>  
#  DESCRIPTION:  passwd tool for PearlPBX auth.sysusers table 
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  2.0
#===============================================================================
use strict;
use warnings;

use PearlPBX::DB qw/pearlpbx_db/; 

my $username = $ARGV[0];
my $password = $ARGV[1];
my $roles    = $ARGV[2] // 'user';

foreach ($username, $password, $roles ) {
    if ( ! defined ( $_ ) ) {
	die usage(); 
    }
}

PearlPBX::DB->new(); 
my $dbh = pearlpbx_db(); 

my @roles_list = split(',',$roles); 
 
my $sql = "select login from auth.sysusers where login=?"; 
my $sql2 = "update auth.sysusers set passwd_hash=?,roles=? where login=?"; 
my $sql3 = "insert into auth.sysusers (login,passwd_hash,roles) values (?,?,?)"; 

my $sth = $dbh->prepare($sql); 
$sth->execute($username); 
my $res = $sth->fetchrow_hashref; 
my $row = $res->{'login'}; 

unless ( defined ($row)) { 
    $sth = $dbh->prepare($sql3); 
    $sth->execute($username,crypt($password,$username), \@roles_list);
    print "Username and password was added successful.\n"; 
    exit(0);
} 

$sth = $dbh->prepare($sql2); 
$sth->execute(crypt($password,$username), \@roles_list, $username); 
print "Password for user $username was replaced successful.\n"; 
exit(0); 

sub usage {
    return "Usage: $0 <username> <password> <admin,[user,reportviewer]>\n"; 
}
1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-gui-passwd.pl

=head1 SYNOPSIS

PearlPBX-gui-passwd.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

