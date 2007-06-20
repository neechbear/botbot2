package plugin::WhoLog;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return;

	$self->{'last_update'} = 0 unless defined($self->{'last_update'});

	if ($event->{'msgtype'} eq 'ALRM') {
		if (time() - $self->{'last_update'} > 60) {
			$self->{'last_update'} = time();
			$self->say('.who');
		}

	} elsif ($event->{msgtype} =~ /^WHO(HDR)?$/) {
		my $mode = /Users on .+ at the moment/ ? '>' : '>>';
		my $file = "./data/who.log";
		if (open(FH, $mode, $file)) {
			print FH "$event->{text}\n";
			close(FH);
		} else {
			warn "Unable to open file handle FH for file '$file': $!";
		}
	}
}

1;

