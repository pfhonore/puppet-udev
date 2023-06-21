# == Class: udev::params
#
# This class should be considered private.
#
class udev::params {
  $config_file_replace = true

  $udev_log     = 'err'
  $rules        = undef

  case $::osfamily {
    'debian': {
      $udev_package    = 'udev'
      $udevlogpriority = 'udevadm control --log-priority'
      $udevtrigger     = 'udevadm trigger --action=change'

      if (versioncmp($::operatingsystemmajrelease, '11') >= 0) {
        $udevadm_path = '/usr/bin'
      } else {
        $udevadm_path = '/sbin'
      }
    }
    'redhat': {
      if $::operatingsystem == 'Fedora' {
        $udevadm_path = '/sbin'
        if (versioncmp($::operatingsystemmajrelease,'20') >=0) {
          $udev_package    = 'systemd'
          $udevtrigger     = 'udevadm trigger'
          $udevlogpriority = 'udevadm control --log-priority'
        }
        else {
          fail("Module ${module_name} might not be supported on Fedora release ${::operatingsystemmajrelease}")
        }
      } else {
        $udevadm_path = '/sbin'
        case $::operatingsystemmajrelease {
          '5': {
            $udev_package    = 'udev'
            $udevtrigger     = 'udevtrigger'
            $udevlogpriority = 'udevcontrol log_priority'
          }
          '6': {
            $udev_package    = 'udev'
            $udevtrigger     = 'udevadm trigger --action=change'
            $udevlogpriority = 'udevadm control --log-priority'
          }
          '7', '8', '9': {
            $udev_package    = 'systemd'
            $udevtrigger     = 'udevadm trigger --action=change'
            $udevlogpriority = 'udevadm control --log-priority'
          }
          default: {
            fail("Module ${module_name} is not supported on RedHat release ${::operatingsystemmajrelease}")
          }
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
