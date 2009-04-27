#!/usr/bin/perl

# Test if bindparam () works
$^W = 1;

#   Include lib.pl
use DBI;
use vars qw($COL_NULLABLE);
do "t/lib.pl";

if (!defined(&SQL_VARCHAR)) {
    eval "sub SQL_VARCHAR { 12 }";
}
if (!defined(&SQL_INTEGER)) {
    eval "sub SQL_INTEGER { 4 }";
}

#
#   Main loop; leave this untouched, put tests after creating
#   the new table.
#
while (Testing()) {
    #
    #   Connect to the database
    Test($state or $dbh = Connect (), "connect") or
	ServerError();

    #
    #   Find a possible new table name
    #
    Test($state or $table = FindNewTable($dbh), 'FindNewTable')
	or DbiError($dbh->err, $dbh->errstr);

    #
    #   Create a new table; EDIT THIS!
    #
    Test($state or ($def = TableDefinition($table,
					   ["id",   "INTEGER",  4, 0],
					   ["name", "CHAR",    64, $COL_NULLABLE]) and
		    $dbh->do($def)), 'create', $def)
	or DbiError($dbh->err, $dbh->errstr);


    Test($state or $cursor = $dbh->prepare("INSERT INTO $table"
	                                   . " VALUES (?, ?)"), 'prepare')
	or DbiError($dbh->err, $dbh->errstr);

    #
    #   Insert some rows
    #

    # Automatic type detection
    my $numericVal = 1;
    my $charVal = "Alligator Descartes";
    Test($state or $cursor->execute($numericVal, $charVal), 'execute insert 1')
	or DbiError($dbh->err, $dbh->errstr);

    # Does the driver remember the automatically detected type?
    Test($state or $cursor->execute("3", "Jochen Wiedmann"),
	 'execute insert num as string')
	or DbiError($dbh->err, $dbh->errstr);
    $numericVal = 2;
    $charVal = "Tim Bunce";
    Test($state or $cursor->execute($numericVal, $charVal), 'execute insert 2')
	or DbiError($dbh->err, $dbh->errstr);

    # Now try the explicit type settings
    Test($state or $cursor->bind_param(1, " 4", SQL_INTEGER()), 'bind 1')
	or DbiError($dbh->err, $dbh->errstr);
    Test($state or $cursor->bind_param(2, "Andreas K�nig"), 'bind 2')
	or DbiError($dbh->err, $dbh->errstr);
    Test($state or $cursor->execute, 'execute binds')
	or DbiError($dbh->err, $dbh->errstr);

    # Works undef -> NULL?
    Test($state or $cursor->bind_param(1, 5, SQL_INTEGER()))
	or DbiError($dbh->err, $dbh->errstr);
    Test($state or $cursor->bind_param(2, undef))
	or DbiError($dbh->err, $dbh->errstr);
    Test($state or $cursor->execute)
 	or DbiError($dbh->err, $dbh->errstr);
  

    Test($state or $cursor -> finish, 'finish');

    Test($state or undef $cursor  ||  1, 'undef cursor');

    Test($state or $dbh -> disconnect, 'disconnect');

    Test($state or undef $dbh  ||  1, 'undef dbh');

    #
    #   And now retreive the rows using bind_columns
    #
    #
    #   Connect to the database
    #
    Test($state or $dbh = Connect (), "connect") or
	ServerError();

    Test($state or $cursor = $dbh->prepare("SELECT * FROM $table"
					   . " ORDER BY id"))
	   or DbiError($dbh->err, $dbh->errstr);

    Test($state or $cursor->execute)
	   or DbiError($dbh->err, $dbh->errstr);

    Test($state or $cursor->bind_columns(undef, \$id, \$name))
	   or DbiError($dbh->err, $dbh->errstr);

    Test($state or ($ref = $cursor->fetch)  &&  $id == 1  &&
	 $name eq 'Alligator Descartes')
	or printf("Query returned id = %s, name = %s, ref = %s, %d\n",
		  $id, $name, $ref, scalar(@$ref));

    Test($state or (($ref = $cursor->fetch)  &&  $id == 2  &&
		    $name eq 'Tim Bunce'))
	or printf("Query returned id = %s, name = %s, ref = %s, %d\n",
		  $id, $name, $ref, scalar(@$ref));

    Test($state or (($ref = $cursor->fetch)  &&  $id == 3  &&
		    $name eq 'Jochen Wiedmann'))
	or printf("Query returned id = %s, name = %s, ref = %s, %d\n",
		  $id, $name, $ref, scalar(@$ref));

    Test($state or (($ref = $cursor->fetch)  &&  $id == 4  &&
		    $name eq 'Andreas K�nig'))
	or printf("Query returned id = %s, name = %s, ref = %s, %d\n",
		  $id, $name, $ref, scalar(@$ref));
 
    Test($state or (($ref = $cursor->fetch)  &&  $id == 5  &&
		    !defined($name)))
	or printf("Query returned id = %s, name = %s, ref = %s, %d\n",
		  $id, $name, $ref, scalar(@$ref));

    Test($state or undef $cursor  or  1);

    #
    #   Finally drop the test table.
    #
    Test($state or $dbh->do("DROP TABLE $table"))
	   or DbiError($dbh->err, $dbh->errstr);
}


