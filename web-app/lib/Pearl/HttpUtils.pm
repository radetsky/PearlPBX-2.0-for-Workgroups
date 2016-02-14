package Pearl::HttpUtils;

use warnings;
use strict;

use Pearl::Logger;

use Exporter;
use parent qw(Exporter);
our @EXPORT_OK = qw (http_accept_lang);

sub http_accept_lang {

    # RFC 2616, sec.14
    # Examples:
    # Chrome             'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.8',
    # Safari             'HTTP_ACCEPT_LANGUAGE' => 'uk-ua',
    # Chrome             'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.8,ru;q=0.6',
    # Accept-Language: da, en-gb;q=0.8, en;q=0.7

    my $http_accept_lang_str = shift;
    unless ( defined($http_accept_lang_str) ) {
        Debug("Accept-Language is empty. Return 'en'");
        return 'en';
    }

    my @languages = split( /,\s*/, $http_accept_lang_str );
    unless (@languages) {
        Debug("Accept-Language is empty. Return 'en'");
        return 'en';
    }

    my %accept;
    foreach my $part (@languages) {
        my $q;
        my $pri;

        my ( $lang_name, $prio ) = split( ';', $part );
        unless ( defined($prio) ) {
            $pri = 1; # Если ничего не задано через точку с запятой, то приоритет считается наивысшим = 1
        }
        else {
            # Разбиваем prio через '='
            ( $q, $pri ) = split( '=', $prio );
        }
        my ( $short_code, $region ) = split( '-', $lang_name );
        next if $short_code ne 'en' && !exists( TRANSLATE->{$short_code} );
        if ( !exists( $accept{$short_code} ) || $accept{$short_code} < $pri )
        {
            $accept{$short_code} = $pri;
        }
    }

    foreach my $lang ( sort { $accept{$b} <=> $accept{$a} } keys %accept ) {
        return $lang;
    }

    # Should not happens
    Debug("No supported languages. Return 'en'.");
    return 'en';
}

1;
