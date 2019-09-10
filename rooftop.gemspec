# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rooftop/version'

Gem::Specification.new do |spec|
  spec.name          = "rooftop"
  spec.version       = Rooftop::VERSION
  spec.authors       = ["Ed Jones"]
  spec.email         = ["ed@errorstudio.co.uk"]
  spec.summary       = "An ActiveRecord-like interface to the Rooftop CMS JSON API"
  spec.description   = "An ActiveRecord-like interface to the Rooftop CMS JSON API"
  spec.homepage      = "http://www.rooftopcms.com"
  spec.license       = "GPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "activesupport", ">= 4", "< 7"
  spec.add_dependency "require_all", "~> 1.3"
  spec.add_dependency "her", "~> 0.10"
  spec.add_dependency "faraday-http-cache", "~> 1.2"

end
