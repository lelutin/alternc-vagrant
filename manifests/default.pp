Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

package { 'make':
  ensure => installed,
}

exec { 'build':
  command => 'cd /vagrant/alternc; make build install-alternc',
  creates => '/etc/alternc',
  require => Package['make'],
}

exec { 'install':
  command => '/usr/share/alternc/install/alternc.install',
  creates => '/etc/alternc/bureau.conf',
  require => Exec['build'],
}

