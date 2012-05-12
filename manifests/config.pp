class drqueueipython::config {

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


}