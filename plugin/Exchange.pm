
sub _exchange {
	my $talker = shift;
	my $event = { @_ };
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
	} else {
		$talker->whisper(
				$event->{person},
				"I failed to convert $value $source in to $target; sorry\n"
			);
	}

	return 0;
}

