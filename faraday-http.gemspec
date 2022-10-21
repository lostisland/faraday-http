# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday/http/version'

Gem::Specification.new do |spec|
  spec.name          = 'faraday-http'
  spec.version       = Faraday::Http::VERSION
  spec.authors       = ['iMacTia']
  spec.email         = ['giuffrida.mattia@gmail.com']

  spec.summary       = 'Faraday Adapter for HTTP.rb'
  spec.description   = 'Faraday Adapter for HTTP.rb'
  spec.homepage      = 'https://github.com/lostisland/faraday-http'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/lostisland/faraday-http'
  spec.metadata['changelog_uri'] = 'https://github.com/lostisland/faraday-http/releases'

  spec.files = Dir.glob('lib/**/*') + %w[README.md LICENSE]
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'http', '>= 4.0', '< 6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
