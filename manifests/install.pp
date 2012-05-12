class drqueueipython::install {

  search Ipython::Functions

  # clone from git repository
  exec { "git clone -b ${drqueueipython::git_branch} git://github.com/kaazoo/DrQueueIPython.git":
    cwd     => "/root",
    creates => "/root/DrQueueIPython",
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Package["git-core"],
    notify  => Exec["distribute-install"],
  }

  # install setuptools/distribute Python module
  exec { "python${ipython::python_version} distribute_setup.py":
    cwd         => "/root/DrQueueIPython",
    path        => ["/bin", "/usr/bin", "/usr/sbin"],
    require     => Package["python${ipython::python_version}", "python${ipython::python_version}-dev"],
    refreshonly => true,
    alias       => "distribute-install",
    notify      => Exec["drqueueipython-install"]
  }

  # install from cloned git repository
  pysetup_install { "drqueueipython":
    cwd => "/root/DrQueueIPython",
    reqs => Exec["distribute-install"],
  }

}
