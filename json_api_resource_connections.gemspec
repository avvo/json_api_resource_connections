# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_api_resource_connections/version'

Gem::Specification.new do |spec|
  spec.name          = "json_api_resource_connections"
  spec.version       = JsonApiResourceConnections::VERSION
  spec.authors       = ["Greg"]
  spec.email         = ["greg@avvo.com"]

  spec.summary       = "circuit breaker and cache fallback connections for json api resource v2"
  spec.description   = "circuit breaker and cache fallback connections for json api resource v2"
  spec.homepage      = "https://github.com/avvo/json_api_resource_connections"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "json_api_resource"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
