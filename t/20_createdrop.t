#!/usr/bin/perl

# Test if a table can be created and dropped
use strict;
use Test::More tests => 8;

use DBI;

# Include lib.pl
do "t/lib.pl";

ok (my $dbh = Connect (),		"connect");

ok (my $tbl = FindNewTable ($dbh),	"find new test table");

like (my $def = TableDefinition ($tbl,
		[ "id",   "INTEGER",  4, 0],
		[ "name", "CHAR",    64, 0]),
	qr{^create table $tbl}i,	"table definition");
ok ($dbh->do ($def),			"create table");
my $tbl_file = DbFile ($tbl);
ok (-s $tbl_file,			"file exists");
ok ($dbh->do ("drop table $tbl"),	"drop table");
ok ($dbh->disconnect,			"disconnect");
ok (!-f $tbl_file,			"file removed");
