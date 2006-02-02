package plugin::Exchange;
use base plugin;
use strict;
use Finance::Currency::Convert::XE;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ 'OBSERVE TALK|TALK|LISTTALK|TELL';

	my $talker = $event->{talker};
	return _exchange($talker,$event) if $event->{command} =~ /exchange/i;
	return _currencies($talker,$event) if $event->{command} =~ /currencies/i;

	return 0;
}

sub _exchange {
	my ($talker,$event) = @_;
	my @arg = @{$event->{args}};

	my $obj = Finance::Currency::Convert::XE->new()       
				|| die "Failed to create object\n" ;

	my $gaveValue = 0;
	my $value = 1;
	if ($arg[0] && $arg[0] =~ /([\d\.]+)/) {
		$value = $1;
		$gaveValue = 1;
		shift @arg;
	}

	my $gaveSource = 0;
	my $source = 'GBP';
	if ($arg[0] && $arg[0] =~ /^([A-Z]{3})$/i) {
		$source = uc($1);
		$gaveSource = 1;
		shift @arg;
	}

	my $target = 'GBP';
	if ($arg[0] && $arg[0] =~ /^([A-Z]{3})$/i) {
		$target = uc($1);
		shift @arg;
	} else {
		unless ($gaveValue && $gaveSource) {
			$target = $source;
			$source = 'GBP';
		}
	}

	my $result = $obj->convert(
				'source' => $source,
				'target' => $target,
				'value' => $value,
				'format' => 'text'
		) || warn "Could not convert: ".$obj->error()."\n";

	if ($result) {
		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				"$value $source is $result $target\n"
			);
		return "Converted $value $source to $target";

	} else {
		$talker->whisper(
				$event->{person},
				"I failed to convert $value $source in to $target; sorry\n"
			);
	}

	return 0;
}

sub _currencies {
	my ($talker,$event) = @_;

	my $obj = Finance::Currency::Convert::XE->new()       
				|| die "Failed to create object\n" ;
	my @currencies = $obj->currencies;

	my $c = 0;
	my @lines;
	my $line;
	for (@currencies) {
		$c++;
		$c = 0 unless ($c % 10);
		$line .= "$_   ";
		if ($c == 0) {
			push(@lines,$line);
			$line = '';
		}
	}
	push(@lines,$line) unless $c == 0;

	$talker->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$_
		) for @lines;
	return "Listed currencies that I can convert";
}

1;


