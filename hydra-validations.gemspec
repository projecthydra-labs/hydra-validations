# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydra/validations/version'

Gem::Specification.new do |spec|
  spec.name          = "hydra-validations"
  spec.version       = Hydra::Validations::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["dchandekstark"]
  spec.email         = ["dchandekstark@gmail.com"]
  spec.summary       = %q{Validations for Hydra applications, based on ActiveModel::Validations}
  spec.description   = %q{Validations for Hydra applications, based on ActiveModel::Validations}
  spec.homepage      = "https://github.com/duke-libraries/hydra-validations"
  spec.license       = "APACHE2"
  spec.required_ruby_version = ">= 1.9.3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "app/validators"]

  spec.add_dependency "activemodel", "~> 4.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
