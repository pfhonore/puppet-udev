# @summary Manages the udev package and device rules
#
# This class does not need to be declared in the manifest when using the
# udev::rule defined type.
#
# @example
#   include udev
#
# @param udev_log Configure the log level.
# @param config_file_replace Should we replace an existing /etc/udev/udev.conf file.
# @param rules A hash with `udev::rule` rules.
class udev(
  Enum['err','info','debug'] $udev_log = $udev::params::udev_log,
  Boolean $config_file_replace = $udev::params::config_file_replace,
  Optional[Hash[String, Hash]] $rules = $udev::params::rules,
) inherits udev::params {

  anchor { 'udev:begin': }
  -> package{ $udev::params::udev_package:
    ensure => present,
  }
  -> file { '/etc/udev/udev.conf':
    ensure  => file,
    content => template("${module_name}/udev.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => $config_file_replace,
    notify  => Class['udev::udevadm::logpriority'],
  }
  -> anchor { 'udev:end': }

  Anchor['udev:begin']
  -> class { 'udev::udevadm::trigger': }
  -> Anchor['udev:end']

  Anchor['udev:begin']
  -> class { 'udev::udevadm::logpriority': udev_log => $udev_log }
  -> Anchor['udev:end']

  if $rules {
    create_resources('udev::rule', $rules)
  }
}
