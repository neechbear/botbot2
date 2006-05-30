package plugin::Ispell;
use base plugin;
use strict;
use Text::Aspell;

our $DESCRIPTION = 'Check work spelling with ASpell';
our %CMDHELP = (
		'aspell <word>' => 'Returns spelling suggestions for <word>'
	);

our $speller = Text::Aspell->new;
die unless $speller;
$speller->set_option('lang','en_US');
$speller->set_option('sug-mode','fast');

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^([ai]?spell(ing)?)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;
	return 0 if grep(!/[a-zA-Z\-0-9]/,@{$event->{cmdargs}});

	my @reply = $speller->suggest("@{$event->{cmdargs}}");
	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			join(', ',@reply)
		) if @reply;
	return "Suggested spellings for '@{$event->{cmdargs}}'" if @reply;

	$self->{talker}->whisper(
			$event->{person},
			"Beats me. Try a dictionary! ;-)"
		);
	return 0;
}

1;

