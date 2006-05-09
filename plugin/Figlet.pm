package plugin::Figlet;
use base plugin;
use strict;

our $DESCRIPTION = 'Figlets words';

sub handle {
	my ($self,$event,$responded) = @_;

	if ($event->{alarm} && defined($self->{quiet})) {
		$self->{quiet}-- if $self->{quiet};
		return 0;
	}

	return unless $event->{command} =~ /^figlet$/i;
	return if $self->{quiet};

	if ($event->{text} =~ /^$self->{config}->{username}\s*,?\s+(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)/i ||
		$event->{text} =~ /^\s*(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)\s*,?\s*$self->{config}->{username}/i) {
		$self->{quiet} = 60;
		return 0;
	}

	my $fontdir = '/usr/share/figlet/';
	my $cmd = "figlet -w 65 ";
	if ($event->{cmdargs}->[0] eq '-f' && -f "$fontdir/$event->{cmdargs}->[1].flf") {
		$cmd .= " -f $event->{cmdargs}->[1].flf ";
		shift @{$event->{cmdargs}};
		shift @{$event->{cmdargs}};
	}

	my $output = '';
	my $input = join(' ',@{$event->{cmdargs}});
	if ($input =~ /^[ a-zA-Z0-9,\<\>\(\)\.\-\+\=\!\?\']+$/i) {
		$output = `$cmd "$input"`;
	}

	return 0 unless $output;

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			" $_"
		) for split(/\n/,$output);

	return "Said a figlet word/phrase";
}

1;

