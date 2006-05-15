package plugin::Ispell;
use base plugin;
use strict;
use Lingua::Ispell qw( :all );ingua::Ispell;

our $DESCRIPTION = 'Check work spelling with ISpell';
our %CMDHELP = (
		'ispell <word>' => 'Returns spelling suggestions for <word>'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^([ai]?spell(ing)?)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;
	return 0 if grep(!/[a-zA-Z\-0-9]/,@{$event->{cmdargs}});

	my @reply = ();
	for my $r ( spellcheck( "@{$event->{cmdargs}}" ) ) {
		push @reply, "$r->{'type'}: $r->{'term'}";
	}

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$_
		) for @reply;
	return "Suggested spellings for '@{$event->{cmdargs}}'" if @reply;

	$self->{talker}->whisper(
			$event->{person},
			"Beats me. Try a dictionary! ;-)"
		);
	return 0;
}

1;

