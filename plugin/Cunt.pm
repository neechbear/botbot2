package plugin::Cunt;
use base plugin;
use strict;

our $DESCRIPTION = 'Responds to rude words with cunty fliglets';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return undef unless int(rand(2)) == 1;

	my @words = qw(beaver clit cock cooter cornhole cunt
				douche fuck jizz poontang prick pussy
				queef snatch tits twat fuckhole);
	my %responses = ();

	my $file = "data/rude.txt";
	if (-f $file && open(RUDE,"<","data/rude.txt")) {
		@words = ();
		while (local $_ = <RUDE>) {
			s/^\s+|\s+$//g;
			my ($word,$response) = $_ =~ /^(\S+)(?:\s+(.+))?/;
			push @words,$word;
			$responses{$word} = $response;
		}
		close(RUDE);
	}

	return unless grep(/^$event->{command}$/i,@words);

	my $data = '';
	if (!defined($responses{$event->{command}}) &&
			$event->{command} =~ /^[a-z0-9]+$/i) {
		$data = `figlet "$event->{command}"`;

	} elsif ($responses{$event->{command}} =~ /^[ a-zA-Z0-9,\.\-\+\=\!]+$/i) {
		$data = `figlet "$responses{$event->{command}}"`;
	}

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			" $_"
		) for split(/\n/,$data);

	return "Said a rude word";
}

1;

