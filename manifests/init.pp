class drqueueipython ($role='slave', $master='127.0.0.1', $public_key='', $install_method='git', $drqueue_version='1.0', $git_branch='master', $git_tag='', $python_version = '2.7') {
  include drqueueipython::config, drqueueipython::install
}
