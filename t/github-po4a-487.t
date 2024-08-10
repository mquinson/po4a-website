#!/usr/bin/env perl

# https://github.com/mquinson/po4a/issues/487

use strict;
use warnings;

use Test::More tests => 18;
use LWP 6.67;

my $debug = ($ENV{DEBUG} || "no") eq "yes";

$debug and do { use Data::Dumper };

my $host = "http://localhost:8000";
if (($ENV{SITE_ENV} || "development") eq "production") {
    $host = "https://www.po4a.org";
}

my $browser = LWP::UserAgent->new;

sub served_in_prefered_language {
    my ($path, $options, $target) = @_;

    my $url = "$host$path";
    my $response = $browser->get($url,
                                 'Accept-Language' => $options->{'Accept-Language'} || 'en-US,en;q=0.9,nl;q=0.8',
                                 Accept => $options->{'Accept'} || '*');
    $debug and print STDERR Dumper $response;

    ok($response->is_success, "$target is available");
    is($response->content_type, "text/html", "$target is in HTML");
    is($response->content_language, $options->{expected_language} || "en", "$target is in expected language");
}

served_in_prefered_language("/", {}, "English");
served_in_prefered_language("/", { Accept => 'text/html' }, "HTML and English");

served_in_prefered_language("/", { 'Accept-Language' => 'en-US,en;q=0.9,de;q=1,nl;q=0.7',
                                   expected_language => 'de' },
                            "German");

served_in_prefered_language("/", { 'Accept-Language' => 'en-US,en;q=0.9,de;q=1,nl;q=0.7',
                                   Accept => 'text/html',
                                   expected_language => 'de' },
                            "HTML and German");

served_in_prefered_language("/", { 'Accept-Language' => 'en-US,en;q=0.9,de;q=1',
                                   Accept => 'text/html',
                                   expected_language => 'de' },
                            "HTML and German without Nederlands");

served_in_prefered_language("/man/man1/po4a.1.php.sr_Cyrl",
                            { expected_language => 'sr-cyrl-rs' },
                            "Serbian Cyrillic");

0;
