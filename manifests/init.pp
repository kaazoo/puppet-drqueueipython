class drqueueipython (
  $role = 'slave',
  $master = '127.0.0.1',
  $mongodb = '127.0.0.1',
  $public_key = '',
  $private_key = '',
  $install_method = 'git',
  $drqueue_version = '1.0',
  $git_branch = 'master',
  $git_tag = '',
  $python_version = '2.7',
  $renderer = 'blender') {

  include drqueueipython::config, drqueueipython::install

}
