# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safer_tokens/version'

Gem::Specification.new do |spec|
  spec.name          = "safer_tokens"
  spec.version       = SaferTokens::VERSION
  spec.authors       = ["Sebastian Skałacki"]
  spec.email         = ["skalee@gmail.com"]
  spec.summary       = %q{Random tokens API for ActiveRecord}
  spec.description   = %q{Generating and finding by random tokens in ActiveRecord. Designed with security in mind.}

  spec.homepage      = "https://github.com/skalee/safer_tokens"
  spec.license       = "Ruby, ISC, 2-clause BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.0", "< 5.0"

  spec.add_development_dependency "bcrypt"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "scrypt"
end
