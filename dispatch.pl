#!/usr/bin/perl

use config qw(%conf);

use Net::SCP qw(scp iscp);

$scp = Net::SCP->new("oss-bos", "robot");
$scp->cwd("/tmp") or die $scp->{errstr};
$scp->put("$conf{userFile}") or die $scp->{errstr};
