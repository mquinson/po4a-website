#!/usr/bin/env perl

# https://gitlab.com/osci/community-cage-infra-ansible/-/merge_requests/681

use strict;
use warnings;

use Test::More tests => 15;
use LWP 6.67;

my $debug = ($ENV{DEBUG} || "no") eq "yes";

$debug and do { use Data::Dumper };

my $host = "http://localhost:8000";
if (($ENV{SITE_ENV} || "development") eq "production") {
    $host = "https://www.po4a.org";
}

my $browser = LWP::UserAgent->new;

sub served_in_prefered_language {
    my ($path, $language) = @_;

    my $url = "$host$path";
    my $response = $browser->get($url);
    $debug and print STDERR Dumper $response;

    ok($response->is_success, "$path is available");
    is($response->content_type, "text/html", "$path is in HTML");
    is($response->content_language, $language || "en", $path);
}

served_in_prefered_language("/index.php.nb-no", "nb-no");
served_in_prefered_language("/documentation.php.nb-no", "nb-no");

served_in_prefered_language("/index.php.sr-cyrl-rs", "sr-cyrl-rs");
served_in_prefered_language("/index.php.zh-hans", "zh-hans");
served_in_prefered_language("/index.php.zh-hant", "zh-hant");

0;
