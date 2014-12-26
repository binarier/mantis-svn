#!/usr/bin/perl

use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use config qw(%conf);

chomp($user = <STDIN>);
chomp($pass = <STDIN>);

# Connect to target DB
my $dbh = DBI->connect("DBI:mysql:database=mantis;host=localhost","mantis","mantis", {'RaiseError' => 1});

# query 
my $sqr = $dbh->prepare("select * from mantis_user_table where username=? and password=?");
$sqr->execute($user, md5_hex($pass));

$e = $sqr->rows;
$sqr->finish();
$dbh->disconnect();

exit 1-$e;
