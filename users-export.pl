#!/usr/bin/perl

use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use File::Basename;
use lib dirname (__FILE__);
use config qw(%conf);

# Connect to target DB
my $dbh = DBI->connect("DBI:mysql:database=$conf{dbName};host=$conf{dbHost}","$conf{dbUser}","$conf{dbPass}", {'RaiseError' => 1});

# query 
my $sqr = $dbh->prepare("select username, password from mantis_user_table");

$sqr->execute();

my($username, $password);

$sqr->bind_columns(undef, \$username, \$password);

my $filename=$conf{userFile};

open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

while($sqr->fetch())
{
  print $fh "$username,$password\n";
}
close $fh;

$sqr->finish();
$dbh->disconnect();


