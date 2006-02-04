package FactStore;
use strict;
use DBI;

sub new {
    my ($class, $filename) = @_;
    $class = ref $class || $class;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$filename", "", "", {RaiseError => 1, PrintWarn => 0, PrintError => 0});
    my $self = { dbh => $dbh };
    bless $self, $class;
    return $self;
}

sub dbh { return shift()->{dbh} };

sub init_wrap {
    my ($self, $method, @args) = @_;
    my @out;
    eval { @out = $self->$method(@args) };
    if ($@ =~ /no such table/) {
	# schtop, this database is not ready yet
	$self->init_db;
	@out = $self->$method(@args);
	return wantarray ? @out : $out[0];
    }
    elsif ($@) {
	# rethrow
	die "$@ (caught by init_wrap)";
    } 
    return wantarray ? @out : $out[0];
}

sub store_fact { 
    my $self = shift;
    $self->init_wrap("_store_fact", @_);
};

sub _store_fact {
    my ($self, $thing1, $verb, $thing2) = @_;
    my $sth = $self->dbh->prepare("INSERT OR REPLACE INTO facts (thing1c, thing2c, thing1, verb, thing2) VALUES (?,?,?,?,?)");
    my $thing1c = $self->canonicalise($thing1);
    my $thing2c = $self->canonicalise($thing2);
    $sth->execute($thing1c, $thing2c, $thing1, $verb, $thing2);
}

sub init_db {
    my $self = shift;
    $self->dbh->do
	(qq(
	    create table facts (
				thing1c varchar(150),
				thing2c varchar(150),
				thing1 varchar(150),
				verb varchar(10),
				thing2 varchat(150),
				primary key (thing1c, thing2c)
				)));
}

sub iq {
    my $self = shift;
    return $self->init_wrap("_iq", @_);
};

sub _iq {
    my $self = shift;
    my ($count) = $self->dbh->selectrow_array("select count(*) from facts");
    return $count || 0;
}

sub random_query {
    my $self = shift;
    return $self->init_wrap("_random_query", @_);
}

sub _random_query {
    my ($self, $query) = @_;
    $query = $self->canonicalise($query);
    my $dbh = $self->dbh;
    my $retrieve = $dbh->selectall_arrayref("select thing1, verb, thing2 from facts where thing1c = ".$dbh->quote($query)." order by thing1c, thing2c");
    return if !@$retrieve;
    my $which = (@$retrieve > 1) ? int(rand(@$retrieve - 1)+.5) : 0;
    my $hwhich = $which + 1;
    return ((join " ", @{$retrieve->[$which]})." ($hwhich of ".(scalar @$retrieve).")");
}

sub canonicalise {
    my ($self, $word) = @_;
    $word =~ s/[^a-zA-Z0-9]//g;
    return lc $word;
}

sub parse_line {
    my ($self, $line) = @_;
    chomp $line;
    my $found = 0;
    while ($line =~ /(.+)\W+(is|are)\W+(.+?)([\.\!\?] | $ )/gx)
    {
	$self->store_fact($1, $2, $3);
	$found++;
    };
    return $found;
}

sub chat {
    my ($self, $they_said) = @_;
    my $i_say;
    if ($they_said =~ /^(.+)\?$/) {
	# interpret as query
	$i_say = $self->random_query($1);
    }
    $self->parse_line($they_said);
    return $i_say if defined $i_say;
    return;
}

1;
