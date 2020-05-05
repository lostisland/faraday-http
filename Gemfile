# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'faraday',
    git: 'https://github.com/lostisland/faraday.git',
    branch: 'master'

# Required gems to run all Faraday tests
gem 'multipart-parser'

group :lint, :development do
  gem 'rubocop', '~> 0.82.0'
  gem 'rubocop-performance', '~> 1.0'
end
