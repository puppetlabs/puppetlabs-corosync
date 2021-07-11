# @summary Configures sane defaults based on the operating system.
class corosync::params {
  $enable_secauth                      = true
  $authkey_source                      = 'file'
  $authkey                             = '/etc/puppet/ssl/certs/ca.pem'
  $port                                = 5405
  $bind_address                        = $facts['networking']['ip']
  $force_online                        = false
  $check_standby                       = false
  $log_timestamp                       = false
  $log_file                            = true
  $debug                               = false
  $log_stderr                          = true
  $syslog_priority                     = 'info'
  $log_function_name                   = false
  $package_corosync                    = true
  $package_pacemaker                   = true
  $version_corosync                    = 'present'
  $version_crmsh                       = 'present'
  $version_pacemaker                   = 'present'
  $version_pcs                         = 'present'
  $version_fence_agents                = 'present'
  $enable_corosync_service             = true
  $manage_corosync_service             = true
  $enable_pacemaker_service            = true
  $enable_pcsd_service                 = true
  $package_quorum_device               = 'corosync-qdevice'
  $set_votequorum                      = true
  $manage_pacemaker_service            = true
  $test_corosync_config                = true

  case $facts['os']['family'] {
    'RedHat': {
      $package_crmsh  = false
      $package_pcs    = true
      $package_fence_agents = true
      $package_install_options = undef
    }

    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          if Numeric($facts['os']['release']['major']) > 9 {
            $package_crmsh = false
            $package_pcs = true
            $package_fence_agents = false
            $package_install_options = undef
          } else {
            $package_crmsh  = true
            $package_pcs    = false
            $package_fence_agents = false
            $package_install_options = undef
          }
        }
        'Ubuntu': {
          if Numeric($facts['os']['release']['major']) > 14 {
            $package_crmsh = false
            $package_pcs = true
            $package_fence_agents = false
            $package_install_options = undef
          } else {
            $package_crmsh  = true
            $package_pcs    = false
            $package_fence_agents = false
            $package_install_options = undef
          }
        }
        default: {
          fail("Unsupported flavour of ${facts['os']['family']}: ${facts['os']['name']}")
        }
      }
    }

    'Suse': {
      case $facts['os']['name'] {
        'SLES': {
          $package_crmsh  = true
          $package_pcs    = false
          $package_fence_agents = false
          $package_install_options = undef
        }
        default: {
          fail("Unsupported flavour of ${facts['os']['family']}: ${facts['os']['name']}")
        }
      }
    }

    default: {
      fail("Unsupported operating system: ${facts['os']['name']}")
    }
  }
}
