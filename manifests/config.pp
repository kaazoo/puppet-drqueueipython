class drqueueipython::config {

  class { 'ipython':
    git_tag => 'rel-1.1.0',
  }

  include ipython

  group { "drqueue":
    ensure => "present",
  }

  user { "drqueue":
    ensure     => present,
    gid        => "drqueue",
    home       => "/home/drqueue",
    managehome => true,
    shell      => "/bin/bash",
    require    => Group["drqueue"]
  }

  # configure MongoDB if acting as DrQueue master
  if $drqueueipython::role == "master" {

    # disable & stop default MongoDB
    service { 'mongodb':
      enable => false,
      ensure => stopped,
    }

  }

}