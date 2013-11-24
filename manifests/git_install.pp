class drqueueipython::git_install {

  include ipython::functions
  search Ipython::Functions

  # clone repository & checkout tag if specified
  if $drqueueipython::git_tag != '' {
    exec { "git clone git://github.com/kaazoo/DrQueueIPython.git drqueueipython && cd drqueueipython && git checkout ${drqueueipython::git_tag}":
      cwd     => '/root',
      creates => '/root/drqueueipython',
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      require => Package['git-core'],
      notify  => Exec['drqueueipython-install'],
    }
  } else {
    # clone repository & switch to specific branch
    exec { "git clone -b ${drqueueipython::git_branch} git://github.com/kaazoo/DrQueueIPython.git drqueueipython":
      cwd     => '/root',
      creates => '/root/drqueueipython',
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      require => Package['git-core'],
      notify  => Exec['drqueueipython-install'],
    }
  }

  # install from cloned git repository
  pysetup_install { "drqueueipython":
    cwd => '/root/drqueueipython',
    reqs => Class['ipython::install'],
  }

  # create DrQueue directory structure if acting as master
  if $drqueueipython::role == "master" {
    exec { "create_drqueue_dirs":
      command     => "python${drqueueipython::python_version} setup.py create_drqueue_dirs --owner=drqueue --group=drqueue --basepath=/usr/local/drqueue",
      cwd         => '/root/drqueueipython',
      path        => ['/bin', '/usr/bin', '/usr/sbin'],
      subscribe   => Pysetup_install['drqueueipython'],
      refreshonly => true,
    }
  }

}
