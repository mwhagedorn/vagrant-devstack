package { "git":
  ensure => "installed",
}

vcsrepo { "/opt/stack/devstack":
  ensure   => present,
  provider => git,
  source   => "https://github.com/openstack-dev/devstack.git",
  require  => [ Package['git'], Exec['/root/devstack/tools/create-stack-user.sh'] ],
}

vcsrepo { "/root/devstack":
  ensure   => present,
  provider => git,
  source   => "https://github.com/openstack-dev/devstack.git",
  require  => Package['git'],
}

file { "/opt/stack/devstack":
  ensure => directory,
  recurse => true,
  owner => "stack",
  group => "stack",
  require => Vcsrepo['/opt/stack/devstack'],
}

file { "/opt/stack/devstack/local.sh":
  ensure => present,
  source => "/vagrant/files/local.sh",
  owner => "stack",
  group => "stack",
  require => Vcsrepo['/opt/stack/devstack'],
}

file { "/opt/stack/devstack/local.conf":
  ensure => present,
  content => template("/vagrant/files/local.conf.erb"),
  owner => "stack",
  group => "stack",
  require => Vcsrepo['/opt/stack/devstack'],
}

file { "/root/devstack":
  ensure => "absent",
  purge => true,
  recurse => true,
  force => true,
  require => Exec['/root/devstack/tools/create-stack-user.sh'],
}

file { "/etc/motd":
  ensure => present,
  source => "/vagrant/files/motd",
  owner => "root",
  group => "root",
  mode => 644,
}

exec {"/root/devstack/tools/create-stack-user.sh":
  cwd => '/root',
  environment => ["HOME=/root"],
  user => 'root',
  group => 'root',
  command => "/root/devstack/tools/create-stack-user.sh",
  logoutput => false,
  timeout => 0,
  returns => 0,
  require => Vcsrepo['/root/devstack'],
}

exec {"/opt/stack/devstack/stack.sh":
  require => [
    File["/opt/stack/devstack/local.conf"],
    File["/opt/stack/devstack/local.sh"],
    Exec["/root/devstack/tools/create-stack-user.sh"],
    Vcsrepo['/opt/stack/devstack'],
  ],
  cwd => '/opt/stack/devstack',
  environment => ["HOME=/opt/stack"],
  user => 'stack',
  group => 'stack',
  command => "/opt/stack/devstack/stack.sh",
  logoutput => false,
  timeout => 0,
  returns => 0,
}
