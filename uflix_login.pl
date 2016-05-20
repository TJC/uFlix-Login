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

if (is_ip_valid($r)) {
    exit 0;
}

my $xfToken = find_xftoken($r->content);
$r = $ua->post("https://uflix.com.au/u/my/auth-ip",
    Content => {
        submit => "Check and Update",
        "_xfToken" => $xfToken,
    },
);
if ($r->code == 303) {
    my $next_hop = $r->header("Location");
    $r = $ua->get($next_hop);
}

if ($r->code != 200) {
    say "Something went wrong.";
    say $r->status_line;
    say $r->content;
    exit 1;
}

exit 0;


# Ugly regex to find hidden input value; should really do HTML parsing properly..
sub find_xftoken {
    my $content = shift;
    my ($token) = $content =~ /input type="hidden" name="_xfToken" value="([a-f\d,]+)"/;
    die "Could not find xfToken value" unless (length $token);
    return $token;
}

sub is_ip_valid {
    my $r = shift;
    return not ($r->content =~ /New IP detected/i);
}

# The site looks like it uses an ajax query to find out if the IP is currently valid.
# The code below *should* work, but doesn't :(
sub ajax_check {
    my $xfToken = find_xftoken($r->content);
    my $r = $ua->post("https://uflix.com.au/u/my/auth-ip?_xfNoRedirect=1&_xfToken=$xfToken&_xfRequestUri=/u/my/auth-ip",
        "Content-Type" => "application/json",
        "Accept" => "application/json"
    );
    say $r->status_line;
    say $r->headers->as_string;
    say $r->content;
}
