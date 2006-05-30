package plugin;

use strict;
use warnings;
no warnings qw(redefine);

use FileHandle;
use POSIX qw(strftime);
use UNIVERSAL;
use Carp qw(carp croak);

# Keep private things private, because there's no
# good reason for people to meddle with them ;-)
my %_private;

sub new {
	my $class = shift;
	my $self = { @_ };

	# Barf if a plugin cannot "handle" an event
	croak unless UNIVERSAL::can($class,'handle');

	# Make private things private
	%_private = %{$self->{_private}};
	delete $self->{_private};

	# Bless you
	$self = bless($self,$class);

	# Backwards compatible flange for plugins
	$self->{talker} = $self;

	DUMP($class,$self);
	return $self
}

sub handle {
	my ($self,$event) = @_;
	$self->log(sprintf('%s was called but has handle() method', ref($self)));
}

sub whisper {
	my $self = shift;
	my $recipient = shift || '';
	my $message = join(' ',@_);

	return unless $recipient =~ /\S+/ && $message =~ /\S+/;
	my $send_str = sprintf(">%s %s", $recipient, $message);
	$send_str =~ s/\n|\r/ /g;
	$_private{'socket'}->print("$send_str\n");
}

sub say {
	my $self = shift;
	my $send_str = join(' ',@_);

	return unless $send_str =~ /\S+/;
	$send_str =~ s/\n|\r/ /g;
	$_private{'socket'}->print("$send_str\n");
}

sub log {
	my $self = shift;
	my $fh = FileHandle->new(">>$self->{logfile}");
	if (defined $fh) {
		my $str = "@_"; chomp $str;
		printf $fh "[%s] %s\n",strftime('%Y-%m-%d %H-%M-%S',localtime), $str;
		$fh->close;
	} else {
		log_warn("Unable to open logfile $self->{logfile} for writing: $!");
	}
}

sub TRACE {};
sub DUMP {};

1;

