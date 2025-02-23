#!/usr/bin/env perl

# https://github.com/mquinson/po4a-website/issues/17

use strict;
use warnings;

use Test::More tests => 8;
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

served_in_html("/index.php.pt_BR", "top page in Brazilian Portuguese");
served_in_html("/documentation.php.pt_BR", "documentation page in Brazilian Portuguese");
served_in_html("/index.php.zh_CN", "top page in Simplified Chinese");
served_in_html("/documentation.php.zh_CN", "documentation page in Simplified Chinese");

0;
