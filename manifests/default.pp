Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

# pre-requisites. dpkg method doesn't automatically bring in dependencies
# Those were taken from ./alternc/debian/control in sections "pre-depends" and
# "depends", minus packages that are usually installed in debian netinst.
package { [
  'acl',
  'debianutils',
  'libapache2-mpm-itk',
  'libapache2-mod-php7.0',
  'php7.0-mysql',
  'phpmyadmin',
  'postfix',
  'proftpd-mod-mysql',
  'proftpd-basic',
  'bind9',
  'wget',
  'rsync',
  'ca-certificates',
  'locales',
  'perl',
  'postfix-mysql',
  'wwwconfig-common',
  'sasl2-bin',
  'libsasl2-modules',
  'php7.0-cli',
  'lockfile-progs',
  'gettext',
  'sudo',
  'adduser',
  'dnsutils',
  'dovecot-core',
  'dovecot-imapd',
  'dovecot-pop3d',
  'dovecot-mysql',
  'vlogger',
  'bsd-mailx',
  'zip',
  'incron',
  'cron',
  'opendkim',
  'opendkim-tools',
  'dovecot-sieve',
  'dovecot-managesieved',
  'mariadb-client',
  'php7.0-curl',
  'quota',
  'pwgen',
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
  alternc alternc/alternc_mail string mail.example.com
  alternc alternc/mysql/host string localhost
  alternc alternc/mysql/user string sysusr
  alternc alternc/mysql/password password blahblah1
  alternc alternc/mysql/alternc_mail_user string alternc_user
  alternc alternc/mysql/alternc_mail_password password blablah2
  alternc alternc/public_ip string ${::ipaddress}
  alternc alternc/use_private_ip boolean true
  alternc alternc/mysql/remote_user string sysusr
  alternc alternc/mysql/remote_password password blahblah3
  alternc alternc/mysql/client string %
  alternc alternc/retry_remote_mysql boolean false
  alternc alternc/hostingname string debian9
  alternc alternc/desktopname string bureau.example.com
  alternc alternc/internal_ip string 127.0.0.1
  alternc alternc/ns1 string ns1.example.com
  alternc alternc/ns2 string ns2.example.com
  alternc alternc/default_mx string mx.example.com
  alternc alternc/use_local_mysql boolean true
  alternc alternc/use_remote_mysql boolean false
  alternc alternc/alternc_html string /var/www/alternc
  alternc alternc/alternc_mail string /var/mail/alternc
  alternc alternc/alternc_logs string /var/log/alternc/sites
  alternc alternc/mysql/db string alternc
  alternc alternc/sql/backuptype string rotate
  alternc alternc/sql/backupoverwrite string no
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
}

