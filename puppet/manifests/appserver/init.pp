$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  logoutput => on_failure
}

exec { 'apt-get update':
  path => '/usr/bin',
}


# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rvm"
  }
}

class { 'apt_get_update':
  stage => preinstall
}

# --- Packages -----------------------------------------------------------------

package { ['curl', 'build-essential', 'git-core', 'nodejs']:
  ensure => installed
}

package { ['libcurl4-openssl-dev', 'nginx']:
  ensure => installed
}

# --- Ruby ---------------------------------------------------------------------

exec { 'install_rvm':
  command     => "${as_vagrant} 'curl -fsSL https://get.rvm.io | bash -s'",
  creates => "${home}/.rvm",
  require => Package['curl'],
}

exec { 'install_ruby':
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install 2.0.0 --latest-binary --autolibs=enabled && rvm --fuzzy alias create default 2.0.0'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

exec { "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'":
  creates => "${home}/.rvm/bin/bundle",
  require => Exec['install_ruby']
}

exec { "${as_vagrant} 'gem install rails'":
  require => Exec['install_ruby']
}

exec { "${as_vagrant} 'gem install passenger'":
  require => Exec['install_ruby']
}

exec { "${as_vagrant} 'rvmsudo passenger-install-nginx-module --auto'":
  require => Exec['install_ruby']
}

# --- Nginx ---------------------------------------------------------------------

service { "nginx":
    ensure => running,
    enable => true,
    require => Package['nginx']
}

file { "/app":
	ensure => "link",
	target => '/vagrant/app',
  require => File['/vagrant/app']
}

file { "/vagrant/app":
	ensure => "directory",
	mode => '0755',
}

file { 'vagrant-nginx':
  ensure => file,
  source => 'puppet:///modules/nginx/127.0.0.1',
  path => '/etc/nginx/sites-available/127.0.0.1',
  require => Package['nginx'],
}

/* nginx::resource::vhost { 'localhost': */
/*   ensure                => present, */
/*   listen_port           => 80, */
/*   www_root              => '/vagrant/app', */
/*   vhost_cfg_append => { */
/*     'passenger_enabled' => 'on', */
/*     'passenger_ruby'    => '/usr/bin/ruby', */
/*   } */
/* } */
