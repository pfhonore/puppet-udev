# @summary Manage a udev rules file and trigger udev to reload it's device rules upon modification
#
# Note that either the *content* or *source* parameter must be specified unless
# *ensure* is 'absent' and that these parameters are mutually exclusive; you
# can not specify both.
#
# @param ensure Controls the state of the udev rule file.
#
# @param content A literal string of the content that is to appear in udev rule file.  This
#   parameter is mutually exclusive with *source*.
#
# @param source The URI to pull the udev rule file content from.  This parameter is mutually
#   exclusive with *content*.  Eg.  'puppet:///modules/mysite/myrule.rules'.
define udev::rule(
  Enum['present', 'absent'] $ensure  = 'present',
  Optional[String] $content = undef,
  Optional[String] $source  = undef
) {

  include udev

  # only $source or $content are allowed

  $config_base = {
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Class['udev::udevadm::trigger'],
  }

  if $source {
    if $content {
      fail("${title}: parameters \$source and \$content are mutually exclusive")
    }
    $config_content = { source => $source }
  } elsif $content {
    if $source {
      fail("${title}: parameters \$source and \$content are mutually exclusive")
    }
    $config_content = { content => $content }
  } else {
    # one of $source or $content is required unless we're removing the file,
    if $ensure != 'absent' {
      fail("${title}: parameter \$source or \$content is required")
    } else {
      $config_content = {}
    }
  }

  $config = merge($config_base, $config_content)

  create_resources( 'file', { "/etc/udev/rules.d/${title}" => $config } )

}
