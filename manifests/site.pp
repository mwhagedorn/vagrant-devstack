# source: http://stackoverflow.com/questions/18844199/how-to-fetch-a-remote-file-e-g-from-github-in-a-puppet-file-resource
define remote_file ($url, $mode = 0644, $owner = $id, $group = $id){
  exec { "retrieve_$title":
    command => "/usr/bin/wget -q $url -O $title",
    creates => "$title",
  }

  file{ "$title":
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    require => Exec["retrieve_$title"],
  }
}

package { ["git", "vim", "zsh", "tmux", "git-review", "python-flake8"]:
    ensure => "installed",
}

vcsrepo { "/home/vagrant/devstack":
    ensure   => present,
    provider => git,
    source   => "https://github.com/openstack-dev/devstack.git",
    require  => Package['git'],
}

file { "/home/vagrant/devstack":
    ensure  => directory,
    recurse => true,
    owner   => "vagrant",
    group   => "vagrant",
    require => Vcsrepo['/home/vagrant/devstack'],
}

file { "/home/vagrant/devstack/local.sh":
    ensure  => present,
    source  => "/vagrant/files/local.sh",
    owner   => "vagrant",
    group   => "vagrant",
    require => Vcsrepo['/home/vagrant/devstack'],
}

file { "/home/vagrant/venv.sh":
    ensure  => present,
    source  => "/vagrant/files/venv.sh",
    owner   => "vagrant",
    group   => "vagrant",
}

file { "/home/vagrant/devstack/local.conf":
    ensure  => present,
    content => template("/vagrant/files/local.conf.erb"),
    owner   => "vagrant",
    group   => "vagrant",
    require => Vcsrepo['/home/vagrant/devstack'],
}

remote_file { "/home/vagrant/.zshrc":
  url   => "http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc",
  mode  => 0600,
  owner => 'vagrant',
  group => "vagrant",
}

remote_file { "/home/vagrant/.zshrc.local":
  url   => "http://git.grml.org/f/grml-etc-core/etc/skel/.zshrc",
  mode  => 0600,
  owner => 'vagrant',
  group => "vagrant",
}

user { 'vagrant':
  ensure  => present,
  shell   => '/bin/zsh',
  require => Package['zsh'],
}

file { "/etc/motd":
    ensure => present,
    source => "/vagrant/files/motd",
    owner  => "root",
    group  => "root",
    mode   => 644,
}

if $enable_ssh == 'true' {

    file { "/home/vagrant/.ssh":
        ensure => "directory",
        owner  => "vagrant",
        group  => "vagrant",
        mode   => 700,
    }

    file { "/home/vagrant/.ssh/id_rsa":
        ensure   => present,
        source   => "/vagrant/files/id_rsa",
        owner    => "vagrant",
        group    => "vagrant",
        mode     => 600,
        require  => File['/home/vagrant/.ssh'],
    }

    file { "/home/vagrant/.ssh/id_rsa.pub":
        ensure   => present,
        source   => "/vagrant/files/id_rsa.pub",
        owner    => "vagrant",
        group    => "vagrant",
        mode     => 600,
        require  => File['/home/vagrant/.ssh'],
    }

}

if $enable_git == 'true' {

    exec { "git config --global user.name '$git_name'":
        path => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require => Package['git'],
    }

    exec { "git config --global user.email '$git_email'":
        path        => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require     => Package['git'],
    }

    exec { "git config --global gitreview.username '$gitreview_username'":
        path        => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require     => Package['git-review', 'git'],
    }

} else {

    exec { "git config --global user.name 'vagrant'":
        path => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require => Package['git'],
    }

    exec { "git config --global user.email 'vagrant@$fqdn'":
        path        => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require     => Package['git'],
    }

    exec { "git config --global gitreview.username 'vagrant'":
        path        => '/usr/bin/',
        environment => ["HOME=/home/vagrant"],
        require     => Package['git-review', 'git'],
    }

}

if $run_stack == 'true' {

    exec {"/home/vagrant/devstack/stack.sh":
        require => [
          File["/home/vagrant/devstack/local.conf"],
          File["/home/vagrant/devstack/local.sh"],
          Vcsrepo['/home/vagrant/devstack'],
        ],
        cwd => '/home/vagrant/devstack',
        environment => ["HOME=/home/vagrant"],
        user => 'vagrant',
        group => 'vagrant',
        command => "/home/vagrant/devstack/stack.sh",
        logoutput => true,
        timeout => 0,
        returns => 0,
    }

    if $venv == 'true' {

        exec {"/home/vagrant/venv.sh":
            require => [
              File["/home/vagrant/venv.sh"],
              Exec['/home/vagrant/devstack/stack.sh'],
            ],
            cwd => '/home/vagrant',
            environment => ["HOME=/home/vagrant"],
            user => 'vagrant',
            group => 'vagrant',
            command => "/home/vagrant/venv.sh",
            logoutput => true,
            timeout => 0,
            returns => 0,
        }

    }

}
