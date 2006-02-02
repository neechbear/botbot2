
sub _currencies {
	my $talker = shift;
	my $event = { @_ };

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
	return 0;
}

