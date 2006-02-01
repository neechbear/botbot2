package plugin;
use strict;
use FileHandle;

sub new {
	my $class = shift;
	return bless({@_},$class);
}

sub handle {
	my ($self,$event) = @_;
	$self->log(sprintf('%s was called', ref($self)));
}

sub log {
	my $self = shift;
	my $fh = FileHandle->new($self->{logfile},O_WRONLY|O_APPEND);
	if (defined $fh) {
		print $fh "@_";
		$fh->close;
	} else {
		warn "Unable to open logfile $self->{logfile} for writing: $!";
	}
}

1;

