class drqueueipython::pip_install {

  # install via pip
  exec { "pip install drqueueipython==${drqueueipython::drqueue_version}":
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
    require => Class['ipython::install'],
    creates => "/usr/local/bin/drqueue",
  }

}
