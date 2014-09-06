# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watcard/version'

Gem::Specification.new do |spec|
  spec.name          = "watcard"
  spec.version       = Watcard::VERSION
  spec.authors       = ["Tristan Hume"]
  spec.email         = ["tris.hume@gmail.com"]
  spec.summary       = %q{Command line interface for University of Waterloo WatCard}
  spec.description   = %q{Command line interface for University of Waterloo WatCard. Includes commands to see purchase history and output ledger.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "facets"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
