# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'malady/version'

Gem::Specification.new do |spec|
  spec.name          = "malady"
  spec.version       = Malady::VERSION
  spec.authors       = ["Jason Yeo"]
  spec.email         = ["jasonyeo88@gmail.com"]

  spec.summary       = %q{An implementation of lisp that compiles to rubinius bytecode.}
  spec.homepage      = "https://github.com/jsyeo/malady"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
