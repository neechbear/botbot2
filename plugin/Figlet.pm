package plugin::Figlet;
use base plugin;
use String::ShellQuote qw();
use strict;

our $DESCRIPTION = 'Figlets words';

sub handle {
	my ($self,$event,$responded) = @_;

	if ($event->{'msgtype'} eq 'ALRM' && defined($self->{quiet})) {
		$self->{quiet}-- if $self->{quiet};
		return 0;
	}

	return unless $event->{command} =~ /^figlet$/i;
	return if $self->{quiet};

	if ($event->{text} =~ /^$self->{config}->{username}\s*,?\s+(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)/i ||
		$event->{text} =~ /^\s*(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)\s*,?\s*$self->{config}->{username}/i) {
		$self->{quiet} = 300;
		return 0;
	}

	my $nick_margin = 13;
	my $default_width = 79;
	my $width_limit = $default_width - $nick_margin - 1;
	if ($event->{list} =~ /^%/) {
		$width_limit -= length($event->{list})-1 + 3;
	}

	my $fontdir = '/usr/share/figlet/';
	my $cmd = "/usr/bin/figlet -w $width_limit ";

	if ($event->{cmdargs}->[0] eq '-f' && -f "$fontdir/$event->{cmdargs}->[1].flf") {
		$cmd .= " -f $event->{cmdargs}->[1].flf ";
		shift @{$event->{cmdargs}};
		shift @{$event->{cmdargs}};
	}

	my $output = '';
	my $input = join(' ',@{$event->{cmdargs}});
	if (length($input) > 40) {
		my @responses = (
				"That's excessively long to figlet don't you think? Behave!",
				"That's excessively long to figlet don't you think?",
				"You're kidding right? That much for a figlet?",
				"Shhh, behave.",
				"That's rather long isn't it?",
				"Trim it done babes!",
			);
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$responses[rand(@responses)],
			);
		return 0;
	}

	$input = String::ShellQuote::shell_quote($input);
#	if ($input =~ /^[ a-zA-Z0-9,\<\>\(\)\.\-\+\=\!\?\']+$/i) {
		$output = `$cmd $input`;
#	}

	return 0 unless $output;

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			" $_"
		) for split(/\n/,$output);

	return "Said a figlet word/phrase";
}

1;

