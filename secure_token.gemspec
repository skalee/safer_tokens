# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'secure_token/version'

Gem::Specification.new do |spec|
  spec.name          = "secure_token"
  spec.version       = SecureToken::VERSION
  spec.authors       = ["Sebastian Skałacki"]
  spec.email         = ["skalee@gmail.com"]
  spec.summary       = %q{Timing-attack-proof tokens for ActiveRecord}
  spec.description   = %q{Tokens for securing APIs, confirmations etc. TODO}
  spec.homepage      = "https://github.com/skalee/secure_token"
  spec.license       = "Ruby, ISC, 2-clause BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
