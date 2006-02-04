package plugin::Remember;
use base plugin;
use strict;
use URLTools;

our $DESCRIPTION = 'Remember URLs that people have mentioned';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^remember$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});
	$str =~ s/\s+/\.\*/g;

	my @reply;
	if (open(URL,"./data/url.log")) {
		while (local $_ = <URL>) {
			chomp;
			if (/$str/i) {
				my ($time,$person,$url,$tinyurl,$list,$title) = split(/\t/,$_);
				unless ($title) {
					my ($title2,$response) = getHtmlTitle($url);
					$title = $title2;
				}
				unless ($tinyurl) {
					$tinyurl = tinyURL($url) || $url;
				}
				push @reply, "$person once mentioned $tinyurl - $title";
			}
		}
		close(URL);
	}

	@reply = ("Sorry. I don't remember $str.") unless @reply;

	$talker->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$reply[int(rand(@reply))]
		);

	return 0;
}

1;

