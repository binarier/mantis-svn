#!/usr/bin/perl
use Digest::MD5 qw(md5 md5_hex md5_base64);

chomp($user = <STDIN>);
chomp($pass = <STDIN>);
$pass_hex = md5_hex($pass);
 
open(my $data, '<', '/var/lib/mantis-svn/users.csv') or die "Could not open '$file' $!\n";
while (my $line = <$data>) {
  chomp $line;
 
 
my @fields = split "," , $line;

      if ($fields[0] eq $user and $fields[1] eq $pass_hex)
      {
        exit 0;
      } 
 
}
exit -1;
