#!/usr/bin/env perl

# https://github.com/mquinson/po4a-website/issues/16

use strict;
use warnings;

use Test::More tests => 6;
use LWP 6.67;

my $debug = ($ENV{DEBUG} || "no") eq "yes";

$debug and do { use Data::Dumper };

my $host = "http://localhost:8000";
if (($ENV{SITE_ENV} || "development") eq "production") {
    $host = "https://www.po4a.org";
}

my $browser = LWP::UserAgent->new;

sub served_in_html {
    my ($path, $target) = @_;

    my $url = "$host$path";
    my $response = $browser->get($url);
    $debug and print STDERR Dumper $response;

    ok($response->is_success, "$target is available");
    is($response->content_type, "text/html", "$target is in HTML");
}

served_in_html("/index.php.nb_NO", "top page in Norwegian Bokmål");
served_in_html("/index.php.sr_Cyrl", "top page in Cyrillic Serbian");
served_in_html("/index.php.zh_Hant", "top page in Traditional Chinese");

0;
