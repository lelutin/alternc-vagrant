Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

# This manifest installs AlternC in an unattended way.
# It will install a package that's in /vagrant, so this means you need to have
# the alternc source code checked out under here and to have compiled packages.
# See the README for command examples
#
# In order to test changes, you need to compile packages after each code change.
#
# For the install procedure to run successfully, you need to have a
# fully-qualified domain name that's "valid" enough for alternc. so that means
# you need something that has a dot in it. Make sure your vagrant box sets this
# up correctly.
#
# Once vagrant is done provisioning, check out "vagrant ssh-config" to find
# your VM's IP. You can use that IP to access AlternC's control panel in HTTP.

# pre-requisites. dpkg method used for alternc package doesn't automatically
# bring in dependencies Those were taken from ./alternc/debian/control in
# sections "pre-depends" and "depends", minus packages that are usually
# installed in debian netinst, plus mariadb which is only suggested (you could
# tell the package to use a remote database).
package { [
  'acl',
  'adduser',
  'bind9',
  'bsd-mailx',
  'ca-certificates',
  'cron',
  'debianutils',
  'dnsutils',
  'dovecot-core',
  'dovecot-imapd',
  'dovecot-managesieved',
  'dovecot-mysql',
  'dovecot-pop3d',
  'dovecot-sieve',
  'gettext',
  'incron',
  'libapache2-mpm-itk',
  'libapache2-mod-php7.0',
  'libjs-jquery-tablesorter',
  'libjs-jquery-ui',
  'libjs-jquery-ui-theme-redmond',
  'libjs-prettify',
  'libsasl2-modules',
  'locales',
  'lockfile-progs',
  'mariadb-client',
  'mariadb-server',
  'opendkim',
  'opendkim-tools',
  'perl',
  'php7.0-cli',
  'php7.0-curl',
  'php7.0-mysql',
  'phpmyadmin',
  'postfix',
  'postfix-mysql',
  'proftpd-mod-mysql',
  'proftpd-basic',
  'pwgen',
  'quota',
  'rsync',
  'sasl2-bin',
  'sudo',
  'vlogger',
  'wget',
  'wwwconfig-common',
  'zip',
]:
  ensure => installed,
  before => Exec['preseeding'],
}

# If something errors out in the process, to make the preseeding happen
# again, you need to clear out debconf values for the alternc package:
#
# echo purge | debconf-communicate alternc
#
# Of course, you can also vagrant destroy and bring up again.
$preseed_items = @("END")
  # alternc general settings
  alternc alternc/hostingname string AlternC
  alternc alternc/desktopname string ${::fqdn}
  alternc alternc/internal_ip string ${::ipaddress}
  alternc alternc/public_ip string ${::ipaddress}
  alternc alternc/use_private_ip boolean true
  alternc alternc/alternc_html string /var/www/alternc
  alternc alternc/alternc_mail string /var/mail/alternc
  alternc alternc/alternc_logs string /var/log/alternc/sites
  alternc alternc/monitor_ip string 
  alternc alternc/alternc_location string 
  alternc alternc/postrm_remove_datafiles boolean 
  alternc alternc/slaves string 
  # dns settings
  alternc alternc/ns1 string ${::hostname}
  alternc alternc/ns2 string ${::hostname}
  alternc alternc/postrm_remove_bind boolean 
  # mysql settings
  alternc alternc/use_local_mysql boolean true
  alternc alternc/mysql/host string 127.0.0.1
  alternc alternc/mysql/db string alternc
  alternc alternc/mysql/client string localhost
  alternc alternc/mysql/user string sysusr
  alternc alternc/mysql/password password blablah2
  alternc alternc/mysql/alternc_mail_user string alternc_user
  alternc alternc/mysql/alternc_mail_password password blablah2
  alternc alternc/use_remote_mysql boolean 
  alternc alternc/mysql/remote_user string 
  alternc alternc/mysql/remote_password password 
  alternc alternc/retry_remote_mysql boolean 
  alternc alternc/sql/backuptype string rotate
  alternc alternc/sql/backupoverwrite string no
  alternc alternc/postrm_remove_databases boolean 
  # email settings
  alternc alternc/default_mx string ${::hostname}
  alternc alternc/default_mx2 string 
  alternc alternc/postrm_remove_mailboxes boolean 
  # quota settings
  alternc alternc/quotauninstalled note false
  | END
exec { 'preseeding':
  command => "echo -e \"${preseed_items}\" | debconf-set-selections",
  unless  => 'test `echo get alternc/alternc_mail | debconf-communicate alternc 2>/dev/null | grep mail.example.com | wc -l` = 1',
}

package { 'alternc':
  ensure   => installed,
  provider => 'dpkg',
  source   => '/vagrant/alternc_3.3.10_all.deb',
  require  => Exec['preseeding'],
  notify   => Exec['alternc.install'],
}

# Finish installation: the package doesn't finish its job
exec { 'alternc.install':
  command     => '/usr/sbin/alternc.install',
  refreshonly => true,
}

