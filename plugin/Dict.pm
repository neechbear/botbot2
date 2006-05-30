package plugin::Dict;
use base plugin;
use strict;
use Net::Dict;

our $DESCRIPTION = 'Return a dictionary definition of a word from dict.org';
our %CMDHELP = (
		'define <query>    ' => 'Get a definition of <query> from dictionary.com',
		'dictionary <query>' => 'Alias for define',
		'dict <query>      ' => 'Alias for define',
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^(dict(ionary)?|define)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	my @reply;
	my $dict = Net::Dict->new('dict.org');
	my $h = $dict->define($str);
	foreach my $i (@{$h}) {
		my ($db, $def) = @{$i};
		my @lines = split(/\n/,$def);
		my $c = 0;
		my $maxlines = 7;
		my $skipped = 1;
		for (@lines) {
			if ($c >= $maxlines && $event->{msgtype} ne 'TELL') {
				push @reply, " ... (truncated; displayed $maxlines lines of ".@lines.") ...";
				last;
			}
			push @reply,$_;
			$c++;
		}
		last;
	}

	unless (@reply) {
		$talker->whisper(
				$event->{person},
				'Sorry, I couldn\'t find a dictionary definition for you'
			);
		return 0;

	} else {
		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;
		return "Gave a dictionary definition for $str";
	}
}

1;


