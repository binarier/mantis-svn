#!/usr/bin/perl

use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);


# Connect to target DB
my $dbh = DBI->connect("DBI:mysql:database=mantis;host=master","mantis","mantis", {'RaiseError' => 1, mysql_enable_utf8 => 1});

my $filename="access-file";
open(my $fh, '>:utf8', $filename) or die "Could not open file '$filename' $!";

print $fh "[groups]\n";

# global public users
#10:viewer,25:reporter,40:updater,55:developer,70:manager,90:administrator
my $queryUsers = $dbh->prepare("select id, username from mantis_user_table where enabled=true and access_level=55");
my ($id, $username);
$queryUsers->execute();
$queryUsers->bind_columns(undef, \$id, \$username);
print $fh "global_public=";
while ($queryUsers->fetch())
{
	print $fh "$username,";
}
print $fh "\n\n";
$queryUsers->finish();

# global admin users
#10:viewer,25:reporter,40:updater,55:developer,70:manager,90:administrator
my $queryUsers = $dbh->prepare("select id, username from mantis_user_table where enabled=true and access_level>=70");
my ($id, $username);
$queryUsers->execute();
$queryUsers->bind_columns(undef, \$id, \$username);
print $fh "global_admin=";
while ($queryUsers->fetch())
{
	print $fh "$username,";
}
print $fh "\n\n";
$queryUsers->finish();


#project groups;
#10:development,30:release,50:stable,70:obsolete
my $sqr = $dbh->prepare("select id, name, description from mantis_project_table where enabled=true and status<70");

$sqr->execute();
my($id, $proj_name, $proj_desc);
$sqr->bind_columns(undef, \$id, \$proj_name, \$proj_desc);

while($sqr->fetch())
{

	next if ($proj_desc !~ /svn:(.*)$/m);

	print $fh "#Project Name: $proj_name\n";
	print $fh "[$1]\n";

	print $fh "\@global_public = r\n";
	print $fh "\@global_admin = rw\n";

	#10:viewer,25:reporter,40:updater,55:developer,70:manager,90:administrator
  $queryUsers = $dbh->prepare("select username from mantis_project_user_list_table pu, mantis_user_table u where pu.user_id = u.id and pu.project_id = ? and pu.access_level >= 55 order by username asc");
  
  $queryUsers->execute($id);
  
  my $username;
  
  $queryUsers->bind_columns(undef, \$username);
  my $first=1;
  while ($queryUsers->fetch())
  {
  	if (!$first)
  	{
  		print $fh ",";
  	}
  	$first=0;
  	print $fh "$username";
  }
  
  if ($first)
  {
  	#none user
#  	print $fh "*=rw\n\n";
  }
  else
  {
    print $fh "=rw";
  }

  print $fh "\n\n";
  
  $queryUsers->finish();
}
close $fh;

$sqr->finish();
$dbh->disconnect();

