# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_resource_controller/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_resource_controller"
  spec.version       = SimpleResourceController::VERSION
  spec.authors       = ["Oleg Zaporozhchenko"]
  spec.email         = ["c3.gdlk@gmail.com"]

  spec.summary       = "Simple gem for resource controllers"
  spec.description   = "This gem allows to write explicit resource controllers"
  spec.homepage      = "https://github.com/c3gdlk/simple_resource_controller"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|coverage)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "jbuilder"
  spec.add_development_dependency 'active_model_serializers', '~> 0.10.0'

  spec.add_dependency "railties"
  spec.add_dependency "actionpack"
  spec.add_dependency "responders"
end
