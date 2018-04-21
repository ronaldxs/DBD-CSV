#!/pro/bin/perl

use 5.14.1;
use warnings;

our $VERSION = "1.20 - 20160520";

sub usage {
    my $err = shift and select STDERR;
    say "usage: $0 [--check | --write]";
    exit $err;
    } # usage

use Getopt::Long qw(:config bundling nopermute);
my $opt_v = 0;
GetOptions (
    "help|?"		=> sub { usage (0); },
    "V|version"		=> sub { say $0 =~ s{.*/}{}r, " [$VERSION]"; exit 0; },

    "c|check!"		=> \my $check,
    "w|write:s"		=> \my $write,
    "v|verbose:1"	=>    \$opt_v,
    ) or usage (1);

use lib "sandbox";
use genMETA;
my $meta = genMETA->new (
    from    => "lib/DBD/CSV.pm",
    verbose => $opt_v,
    );

$meta->quiet (defined $write);
$meta->from_data (<DATA>);

if ($check) {
    $meta->check_encoding ();
    $meta->check_required ();
    $meta->check_minimum ([ "t", "lib" ]);
    $meta->done_testing ();
    }
elsif (defined $write) {
    $meta->write_yaml ($write);
    }
elsif ($opt_v) {
    $meta->print_yaml ();
    }
else {
    $meta->fix_meta ();
    }

__END__
--- #YAML:1.0
name:                    DBD-CSV
version:                 VERSION
abstract:                DBI driver for CSV files
license:                 perl
author:
    - Jochen Wiedmann
    - Jeff Zucker
    - H.Merijn Brand <h.m.brand@xs4all.nl>
    - Jens Rehsack <rehsack@cpan.org>
generated_by:            Author
distribution_type:       module
provides:
    DBD::CSV:
        file:            lib/DBD/CSV.pm
        version:         VERSION
requires:
    perl:                5.008001
    DBI:                 1.628
    DBD::File:           0.42
    SQL::Statement:      1.405
    Text::CSV_XS:        1.01
recommends:
    DBI:                 1.641
    DBD::File:           0.44
    SQL::Statement:      1.412
    Text::CSV_XS:        1.35
configure_requires:
    ExtUtils::MakeMaker: 0
    DBI:                 1.628
build_requires:
    Config:              0
test_requires:
    Test::Harness:       0
    Test::More:          0.90
    Encode:              0
    Cwd:                 0
    charnames:           0
test_recommends:
    Test::More:          1.302136
installdirs:             site
resources:
    license:             http://dev.perl.org/licenses/
    repository:          https://github.com/perl5-dbi/DBD-CSV.git
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
