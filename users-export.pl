#!/usr/bin/perl

use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);

# Connect to target DB
my $dbh = DBI->connect("DBI:mysql:database=mantis;host=master","mantis","mantis", {'RaiseError' => 1});

# query 
my $sqr = $dbh->prepare("select username, password from mantis_user_table");

$sqr->execute();

my($username, $password);

$sqr->bind_columns(undef, \$username, \$password);

my $filename="users.csv";
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

while($sqr->fetch())
{
  print $fh "$username,$password\n";
}
close $fh;

$sqr->finish();
$dbh->disconnect();


