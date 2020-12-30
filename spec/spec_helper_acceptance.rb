require 'voxpupuli/acceptance/spec_helper_acceptance'
require 'voxpupuli/test/spec_helper'

configure_beaker do |host|
  # On Debian-based, service state transitions (restart, stop) hang indefinitely and
  # lead to test timeouts if there is a service unit of Type=notify involved.
  # Use Type=simple as a workaround. See issue 455.
  if host[:hypervisor] =~ %r{docker} && fact_on(host, 'os.family') == 'Debian'
    on host, 'mkdir /etc/systemd/system/corosync.service.d'
    on host, 'echo -e "[Service]\nType=simple" > /etc/systemd/system/corosync.service.d/10-type-simple.conf'
  end
  # Issue 455: On Centos-based there are recurring problems with the pacemaker systemd service
  # refusing to stop its crmd subprocess leading to test timeouts. Force a fast SigKill here.
  if host[:hypervisor] =~ %r{docker} && fact_on(host, 'os.family') == 'RedHat' && fact_on(host, 'os.release.major') == '7'
    on host, 'mkdir /etc/systemd/system/pacemaker.service.d'
    on host, 'echo -e "[Service]\nSendSIGKILL=yes\nTimeoutStopSec=60s" > /etc/systemd/system/pacemaker.service.d/10-timeout.conf'
  end
end

case fact('os.family')
when 'RedHat'
  default_provider = 'pcs'
when 'Debian'
  case fact('os.name')
  when 'Debian'
    if fact('operatingsystemmajrelease') > 9
      default_provider = 'pcs'
    else
      default_provider = 'crm'
    end
  when 'Ubuntu'
    if fact('operatingsystemmajrelease') > 14
      default_provider = 'pcs'
    else
      default_provider = 'crm'
    end
  end
when 'Suse'
  default_provider = 'crm'
end

add_custom_fact :default_provider, default_provider

def cleanup_cs_resources
  pp = <<-EOS
      resources { 'cs_clone' :
        purge => true,
      }
      resources { 'cs_group' :
        purge => true,
      }
      resources { 'cs_colocation' :
        purge => true,
      }
      resources { 'cs_location' :
        purge => true,
      }
    EOS

  apply_manifest(pp, catch_failures: true, debug: false, trace: true)
  apply_manifest(pp, catch_changes: true, debug: false, trace: true)

  pp = <<-EOS
      resources { 'cs_primitive' :
        purge => true,
      }
    EOS

  apply_manifest(pp, catch_failures: true, debug: false, trace: true)
  apply_manifest(pp, catch_changes: true, debug: false, trace: true)
end
