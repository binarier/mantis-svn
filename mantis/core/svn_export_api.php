<?php

$svn_export_base = "/var/lib/mantis-svn";

function svn_export_users() {
	global $svn_export_base;
	system($svn_export_base. "/users-export.pl");
	system($svn_export_base. "/users-dispatch.pl&");
}

function svn_export_auth() {
	global $svn_export_base;
	system($svn_export_base. "/auth-export.pl");
	system($svn_export_base. "/auth-dispatch.pl&");
}

?>
