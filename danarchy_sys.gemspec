# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'danarchy_sys/version'

Gem::Specification.new do |spec|
  spec.name          = "danarchy_sys"
  spec.version       = DanarchySys::VERSION
  spec.authors       = ["Dan James"]
  spec.email         = ["danheneise@me.com"]

  spec.summary       = %q{Facilitates the deployment and management of OpenStack.}
  spec.description   = %q{dAnarchy Sys is intended to be a platform for the management of cloud compute instances from initial setup through to the deployment of end-user software.}
  spec.homepage      = "https://github.com/danarchy85/danarchy_sys"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fog-openstack", "~> 0.1", ">=0.1.20"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
