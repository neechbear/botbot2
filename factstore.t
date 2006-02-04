#!/usr/bin/perl -w
use strict;
use Test::More tests => 14;
use FactStore;

unlink ("foo.sqi");
my $inst = FactStore->new ("foo.sqi");
ok($inst, "created");

is($inst->iq,0, "We are stupid and know nothing");
ok(!defined $inst->random_query("ducks"), "... ergo, nothing about ducks");

$inst->store_fact("badgers","are","green");
ok(1, "still here, with badgers");
is($inst->iq,1, "We now know ONE thing");
ok(!defined $inst->random_query("ducks"), "... ergo, still nothing about ducks");
$inst->store_fact("badgers","are","green");
is($inst->iq,1, "We still know one thing");
$inst->store_fact("BADGERS","are","green");
is($inst->iq,1, "We still know one thing");
$inst->store_fact("bouncy spring lambs", "are", "great when cooked with rosemary");
is($inst->iq,2, "We have learned something else. And we are not a vegan");
$inst->store_fact("badgers","are","tuberculosis vectors");
is($inst->iq,3, "Hazard: badgers");
diag ("Testing randomness");
my $i = 0;
my $limit = 100000;
my %seen;
while (keys %seen < 2) {
    my $statement = $inst->random_query("badgers");
    ($statement =~ /^badger/i) or die "Oh dear, undef";
    $seen{$statement} = 1;
    die "gave up" if $i++ > $limit;
}
ok(1, "Retrieved both badgerfacts");
ok(!defined $inst->chat(""), "quiet if quiet");
ok($inst->chat("badgers?"), "talk of stripy creatures");
$inst->chat("fish are like creatures that go POOK POOK");
ok($inst->random_query("fish") =~ /pook/i, "pook");
