Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

# build depends
package { 'make':
  ensure => installed,
  before => Exec['build'],
}

# pre-requisites
# see: apt-cache show alternc | grep "^Depends:\|^Pre-Depends:\|^Recommends:"
package { [
    # Depends
    'apache2-mpm-itk',
    'libapache2-mod-php5',
    'php5-mysql',
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
    'php5-cli',
    'lockfile-progs',
    'gettext',
    'sudo',
    'adduser',
    'mysql-client',
    'dnsutils',
    'dovecot-common',
    'dovecot-imapd',
    'dovecot-pop3d',
    'dovecot-mysql',
    'vlogger',
    'bsd-mailx',
    'incron',
    'cron',
    'opendkim',
    'opendkim-tools',
    'dovecot-sieve',
    'dovecot-managesieved',
    'php5-curl',
    # Pre-Depends
    'debconf',
    'bash',
    'acl',
    # Recommends
    'mysql-server',
    'ntp',
    'quota',
    'unzip',
    'bzip2',
  ]:
  ensure => installed,
  before => Exec['install'],
}

exec { 'build':
  command => 'sh -c "cd /vagrant/alternc; make build install-alternc"',
  creates => '/etc/alternc',
}

# FIXME: alternc.install needs /etc/alternc/local.sh but this is only generated
# by the debian package's postinstall script.
exec { 'install':
  command => '/usr/share/alternc/install/alternc.install',
  creates => '/etc/alternc/bureau.conf',
  require => Exec['build'],
}

