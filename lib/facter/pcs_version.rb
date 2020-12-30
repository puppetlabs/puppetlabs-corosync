Facter.add(:pcs_version) do
  confine kernel: ['Linux']
  setcode do
    pcs_version = nil

    if Facter::Util::Resolution.which('pcs')
      pcs_version = Facter::Util::Resolution.exec('pcs --version')
      Facter.debug "Matching pcs '#{pcs_version}'"
    end

    unless pcs_version.nil?
      match = %r{^(\d+.\d+.\d+)$}.match(pcs_version)
      unless match.nil?
        match[1]
      end
    end
  end
end
