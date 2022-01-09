
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "danarchy_couchdb/version"

Gem::Specification.new do |spec|
  spec.name          = "danarchy_couchdb"
  spec.version       = DanarchyCouchDB::VERSION
  spec.authors       = ["Dan James"]
  spec.email         = ["dan@danarchy.me"]

  spec.summary       = %q{dAnarchy CouchDB connector.}
  spec.description   = %q{A CouchDB API connector for dAnarchy gems.}
  spec.homepage      = "https://github.com/danarchy85/danarchy_couchdb"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
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

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.0"
  # spec.add_development_dependency "rspec", "~> 3.0"
end
