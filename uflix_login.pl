#!/usr/bin/env perl
use 5.12.0;
use warnings;
use LWP::UserAgent;

my $username = $ENV{UFLIX_USER};
my $password = $ENV{UFLIX_PASS};

die "You must set UFLIX_USER and UFLIX_PASS before running the script\n"
    unless (defined $username and defined $password);

my $ua = LWP::UserAgent->new;
$ua->cookie_jar({});

my $r = $ua->post("https://uflix.com.au/u/login/login",
    Content => {
        login => $username,
        password => $password,
        remember => 1,
        submit => "Log in",
    },
);

if ($r->code != 303) {
    say "Error logging in!";
    say $r->status_line;
    say $r->as_string;
    exit 1;
}

my $next_hop = $r->header("Location");
$r = $ua->get($next_hop);
if ($r->code != 200) {
    say "Error checking account status!";
    say $r->status_line;
    exit 1;
}

exit 0;
