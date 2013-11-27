class drqueueipython::install {

  include apt


  # install IPython
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

  # install required renderer if acting as DrQueue slave
  } elsif $drqueueipython::role == 'slave' {

    # install Blender
    if $drqueueipython::renderer == 'blender' {

      # add repository
      apt::source { 'blender':
        location    => 'http://ppa.launchpad.net/irie/blender/ubuntu',
        release     => 'precise',
        repos       => 'main',
        key         => 'C4A100CF',
        key_server  => 'keyserver.ubuntu.com',
        include_src => false
      }

      # install package
      if ! defined(Package['blender']) {
        package { ['blender']:
          ensure  => present,
          require => Apt::Source['blender'],
        }
      }
    }

    # install sshfs
    if ! defined(Package['sshfs']) {
      package { ['sshfs']:
        ensure  => present,
      }
    }

  } else {
    err('unsupported role value')
  }

}
