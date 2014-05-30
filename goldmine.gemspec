# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "goldmine/version"

Gem::Specification.new do |spec|
  spec.name          = "goldmine"
  spec.version       = Goldmine::VERSION
  spec.authors       = ['Marcin "Archetylator" Syngajewski']
  spec.email         = ["archetelecynacja@gmail.com"]
  spec.summary       = %q{A simple, fortune cookie library for Ruby}
  spec.homepage      = "http://github.com/Archetylator/goldmine"
  spec.license       = "Beerware"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib", "fortunes"]

  spec.add_dependency "bitswitch", "~> 1.1.4"

  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "bundler", "~> 1.3"
end
