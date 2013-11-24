class drqueueipython::install {

  include apt


  class { 'ipython':
    python_version => $drqueueipython::python_version,
  }
  include ipython

  # run install via pip
  if $drqueueipython::install_method == 'pip' {

    include drqueueipython::pip_install

  # run install via git
  } elsif $drqueueipython::install_method == 'git' {

    include drqueueipython::git_install

  } else {
    err('unsupported install method')
  }

  # install MongoDB if acting as DrQueue master
  if $drqueueipython::role == "master" {

    # add repository
    apt::source { 'mongodb':
      location    => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
      release     => 'dist',
      repos       => '10gen',
      key         => '7F0CEB10',
      key_server  => 'keyserver.ubuntu.com',
      include_src => false
    }

    # install package
    if ! defined(Package["mongodb-10gen"]) {
      package { ["mongodb-10gen"]:
        ensure  => present,
        require => Apt::Source['mongodb'],
      }
    }

  }

}
