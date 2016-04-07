#!/usr/bin/perl

use warnings;
use strict;

# We use Plack*
use Plack::Request;
use Plack::Builder;
use Plack::App::Directory;

# Own modules to present Pages and Actions
use PearlPBX::Pages;
use PearlPBX::Actions;

use Pearl::Const; 

use Plack::Middleware::PearlPBX::Authenticate;
use Plack::Middleware::PearlPBX::Page500;
use Plack::Middleware::StackTrace;
use Plack::Middleware::Session;
use Plack::Session::State::Cookie;
use Plack::Session::Store::Cache;

use CHI;
use Cache::Memcached::Fast;
use CHI::Driver::Memcached::Fast;

# -------------- Plack application ------------

my $app = builder {
    mount "/" => builder { 	
        mount "/img" =>
            Plack::App::Directory->new( root => WWW_ROOT . '/img' )
            ->to_app;
        mount "/css" =>
            Plack::App::Directory->new( root => WWW_ROOT . '/css' )
            ->to_app;
        mount "/js" =>
            Plack::App::Directory->new( root => WWW_ROOT . '/js' )
            ->to_app;
        mount "/html" =>
            Plack::App::Directory->new( root => WWW_ROOT . '/html' )
            ->to_app;
    }; 
    if ( $ENV{STARMAN_DEBUG} ) {
        enable "StackTrace", force => 1;
    }
    else {
        # Enable Page_500 instead of stacktrace on the deployment
        enable 'PearlPBX::Page500';
    }

    enable 'Session', store => Plack::Session::Store::Cache->new(
        cache => CHI->new (
            driver => 'Memcached::Fast',
            namespace          => 'sessions',
            servers            => ["127.0.0.1:11211"],
            compress_threshold => 10_000,
        )
    );

    mount "/login" => builder { \&page_login };
    mount "/action/login" => builder { \&action_login };
   
    mount "/"      => builder { 
	enable 'PearlPBX::Authenticate'; 
	mount "/index" => builder { \&page_index }; 
    }; 
};

