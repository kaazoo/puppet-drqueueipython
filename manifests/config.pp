class drqueueipython::config {

  # add drqueue group
  group { 'drqueue':
    ensure => 'present',
  }

  # add drqueue user
  user { 'drqueue':
    ensure     => present,
    gid        => 'drqueue',
    home       => '/home/drqueue',
    managehome => true,
    shell      => '/bin/bash',
    require    => Group['drqueue']
  }

  # add SSH public key
  if $drqueueipython::public_key != '' {
    ssh_authorized_key { 'drqueue_pubkey':
      ensure => present,
      key    => $drqueueipython::public_key,
      type   => 'ssh-rsa',
      user   => 'drqueue',
    }
  }

  # add environment configuration
  file { '/etc/profile.d/drqueue.sh':
    ensure => present,
    content => template('drqueueipython/drqueue.sh.erb'),
  }

  # add hosts entry
  host { "$hostname":
    ensure => present,
    ip     => '127.0.1.1',
  }

  # configure MongoDB if acting as DrQueue master
  if $drqueueipython::role == 'master' {

    # disable & stop default MongoDB
    service { 'mongodb':
      enable => false,
      ensure => stopped,
    }

    # install controller config
    file { '/usr/local/drqueue/ipython/profile_default/ipcontroller_config.py':
      owner   => 'drqueue',
      group   => 'drqueue',
      mode    => 644,
      content => template('drqueueipython/ipcontroller_config.py.erb'),
      require => Exec['create_drqueue_dirs'],
    }

  } elsif $drqueueipython::role == 'slave' {

    # SSH config directory
    file { '/home/drqueue/.ssh':
      ensure => directory,
      owner  => 'drqueue',
      group  => 'drqueue',
      mode   => 700,
    }

    # DrQueue mountpoint
    file { '/usr/local/drqueue':
      ensure => directory,
      owner  => 'drqueue',
      group  => 'drqueue',
      mode   => 775,
    }

    # extract SSH pubkey from master
    exec { "ssh-keyscan ${drqueueipython::master} 2>/dev/null >>/home/drqueue/.ssh/known_hosts":
      path        => ['/bin', '/usr/bin', '/usr/sbin'],
      require     => File['/home/drqueue/.ssh'],
      unless      => "grep ${drqueueipython::master} /home/drqueue/.ssh/known_hosts",
      user        => 'drqueue',
      environment => ['HOME=/home/drqueue/'],
    }

    # generate SSH keypair
    exec { "ssh-keygen -b 2048 -t rsa -N '' -f /home/drqueue/.ssh/id_rsa":
      path        => ['/bin', '/usr/bin', '/usr/sbin'],
      require     => File['/home/drqueue/.ssh'],
      creates     => '/home/drqueue/.ssh/id_rsa',
      user        => 'drqueue',
      environment => ['HOME=/home/drqueue/'],
    }

    # upstart job
    file { '/etc/init/drqueue_slave.conf':
      ensure  => present,
      content => template('drqueueipython/drqueue_slave.conf.erb'),
    }

    # upstart init.d link
    file { '/etc/init.d/drqueue_slave':
      ensure => link,
      target => '/lib/init/upstart-job',
    }

  } else {
    err('unsupported role value')
  }

}