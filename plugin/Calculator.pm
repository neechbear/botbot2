package plugin::Calculator;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $str = $event->{text};
	if ($str =~ /^[\s=0-9pi]+$/i && lc($str) ne 'pi') {
		# Just a number
		# NOOP

	} elsif ($str =~ /^(\s*(?:hex|oct|dec|bin)\s+of\s+)?([pi\=\;\(\)\s\d\+\-\/\.\*\^\%]+)$/i) {
		my $convert = $1 || 'dec';

		my $calc = $2;
		$calc =~ s/pi/\(104348\/33215\)/gi;
		my $changed_calc = 0;
		if ($calc =~ s/[pi]//gi) {
			$changed_calc++;
		}

		my $result = eval "($calc)+1-1";

		# Convert the result to another base if necessary
		if ($result =~ /^[0-9\.]+$/) {
			my $Xresult = $result;
			if ($convert =~ /\s*hex of\s*/i) {
				$Xresult = sprintf("%X", $result);

			} elsif ($convert =~ /\s*oct of\s*/i) {
				$Xresult = sprintf("%o", $result);

			} elsif ($convert =~ /\s*bin of\s*/i) {
				$Xresult = unpack("B*", pack("N", $result));
			}
			$result = $Xresult;
		}

		if (!$@ && length($result)) {
			$self->{talker}->whisper(
					($event->{list} ? $event->{list} : $event->{person}),
					"I didn't like your statement, so I changed it to $convert $calc"
				) if $changed_calc;
			$self->{talker}->whisper(
					($event->{list} ? $event->{list} : $event->{person}),
					"$str = $result"
				);
		}
	}
}

1;

