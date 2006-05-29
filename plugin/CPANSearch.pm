package plugin::CPANSearch;
use base plugin;
use strict;
use XML::Simple;
use LWP::Simple;

our $DESCRIPTION = '';
our %CMDHELP = (
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^cpansearch$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	my $url = 'http://search.cpan.org/search?mode=module&format=xml&query='.$str;
	my $xml = LWP::Simple::get($url);
	my $xs = new XML::Simple();
	my $results = $xs->XMLin($xml, ForceArray => 1, KeyAttr => 'key');

	my @reply;
	for my $r (@{$results}) {
		use Data::Dumper;
		print Dumper($r);
	}

	if (@reply) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;
		return "Returned CPAN search results";
	}

	$self->{talker}->whisper(
			$event->{person},
			"Couldn't find any matching results"
		);
	return 0;
}

1;

