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

  # tell user to source /etc/profile

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

    # TODO: tell user to source /etc/profile

    # TODO: add mountpoint (SSHFS)
    # sshfs 192.168.1.1:/usr/local/drqueue /usr/local/drqueue

  } else {
    err('unsupported role value')
  }

}