mantis-svn
==========

使用Mantis用户体系对SVN进行用户和权限方面的集成

requirement:

mod_authnz_external - 集成到httpd用户认证
perl-Net-SCP - 用于scp分发（可选）

example:

AddExternalAuth ca /var/lib/mantis-svn/csv-auth.pl
SetExternalAuthMethod ca pipe

<Location /svn>
  DAV svn
  SVNParentPath /opt/svn
 
  AuthType Basic
  AuthName "xxx Repository"

  AuthBasicProvider external
  AuthExternal ca

  AuthzSVNAccessFile /opt/svn/svn-access-file
  Require valid-user
  ModMimeUsePathInfo on
  SVNAdvertiseV2Protocol on
</Location>
