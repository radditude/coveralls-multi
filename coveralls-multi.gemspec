
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coveralls-multi/version'

Gem::Specification.new do |spec|
  spec.name          = 'coveralls-multi'
  spec.version       = CoverallsMulti::VERSION
  spec.authors       = ['CJ Horton']
  spec.email         = ['thecjhorton@gmail.com']

  spec.summary       = 'Coveralls client for multi-language repos.'
  spec.description   = 'A configurable Coveralls client that supports merging coverage from multiple languages & test suites.'
  spec.homepage      = 'https://github.com/radditude/coveralls-multi'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = 'coveralls-multi'
  spec.require_paths = ['lib']

  spec.add_dependency 'coveralls-lcov', '~> 1.5.1'
  spec.add_dependency 'httparty', '~> 0.17.3'

  spec.add_development_dependency 'bundler', '> 1.16'
  spec.add_development_dependency 'coveralls', '~> 0.8.22'
  spec.add_development_dependency 'pry', '~> 0.11.3'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'webmock', '~> 3.5.1'
end
