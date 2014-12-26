package config;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(%conf);

our %conf = (
dbHost=>'172.28.0.24',
dbPort=>'3306',
dbName=>'mantis',
dbUser=>'mantis',
dbPass=>'mantis',
accessFile=>'/tmp/mantis-access-file',
userFile=>'/tmp/mantis-user-file'
);
