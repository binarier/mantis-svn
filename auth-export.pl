#!/usr/bin/perl

use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use File::Basename;
use lib dirname (__FILE__);
use config qw(%conf);
use warnings;

# Connect to target DB
my $dbh = DBI->connect("DBI:mysql:database=$conf{dbName};host=$conf{dbHost}","$conf{dbUser}","$conf{dbPass}", {'RaiseError' => 1});

my $filename=$conf{accessFile};
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
$queryUsers = $dbh->prepare("select id, username from mantis_user_table where enabled=true and access_level>=70");
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
my($proj_name, $proj_desc);
$sqr->bind_columns(undef, \$id, \$proj_name, \$proj_desc);

my @projects;

while($sqr->fetch())
{
	next if ($proj_desc !~ /svn:(.*)$/m);
	my $svnurl = $1;
	my @users;
	
	#query for project users
	#10:viewer,25:reporter,40:updater,55:developer,70:manager,90:administrator
	$queryUsers = $dbh->prepare("select username from mantis_project_user_list_table pu, mantis_user_table u where pu.user_id = u.id and pu.project_id = ? and pu.access_level >= 55 order by username asc");
	
	$queryUsers->execute($id);
	
	my $username;
	$queryUsers->bind_columns(undef, \$username);
	while ($queryUsers->fetch())
	{
		push @users, $username;
	}
	$queryUsers->finish();
	my %pr = (
		name		=> $proj_name,
		svnurl	=> $svnurl,
		users		=> \@users,
	);
	push @projects, \%pr;
}
$sqr->finish();
$dbh->disconnect();

#output groups
foreach my $i (0 .. $#projects)
{
	my %project = %{$projects[$i]};
	print $fh "#Project Name: $project{name}\n";
	print $fh "proj_$i = ";
	my $first = 1;
	foreach my $user (@{$project{users}})
	{
		if ($first)
		{
			$first = 0;
		}
		else
		{
			print $fh ",";
		}
		
		print $fh $user;
	}
	print $fh "\n\n";
}

#output permission control
foreach my $i (0 .. $#projects)
{
	my %project = %{$projects[$i]};
	print $fh "[$project{svnurl}]\n";
	print $fh "\@global_public = r\n";
	print $fh "\@global_admin = rw\n";
	print $fh "\@proj_$i = rw\n";
	print $fh "\n";
}
close $fh;


