package plugin::NoiseyPeople;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /wassup|yo|hi'?ya|hi|hello/i;
	return unless $event->{msgtype} eq 'TELL';

	my @foo = @args; pop @foo;
	my $foo = "@foo"; my $bar = uc($foo);
	if ("$foo" eq "$bar" && @foo > 4) {
		LOG("'$foo' eq '$bar'");
		my $list = isList($raw);
		LOG("list = $list");
		if ($person =~ /zoe/i) {
			$talker->say(
					($list !~ /\@/ ? "<<$list" : '<@Public')." ".
					"comforts $person. there there, shhhhhh it'll be okay"
				);
		} else {
			$talker->say(
					($list !~ /\@/ ? ">>$list" : '>@Public')." ".
					"SHHHHHH!"
				);
		}
	} elsif ("@foo" =~ /\bpook/i && int(rand(3)) == 2) {
		my $list = isList($raw);
		$talker->say(
				($list !~ /\@/ ? ">>$list" : '>@Public')." ".
				"pook"
			);
	} elsif ( ( ($foo[0] =~ /mew|mews/i && @foo == 1) ||
				"@foo" =~ /mew(\s+mew)+/i ) && int(rand(3)) == 2) {
		my $list = isList($raw);
		if (int(rand(3)) == 2) {
			$talker->say(
					($list !~ /\@/ ? "<<$list" : '<@Public')." ".
					"purrs"
				);
		} else {
			$talker->say(
					($list !~ /\@/ ? ">>$list" : '>@Public')." ".
					"mew"
				);
		}
	}

	if ($person =~ /pkent/i) {
		if ($raw =~ /christian|religion|\bsan\b|\bvpn\b|\bnas\b|catholic/i) {
			$talker->say(".kick $person NO!");
		}
	}
}

1;

