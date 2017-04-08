# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lazy_record/version'

Gem::Specification.new do |spec|
  spec.name          = 'lazy_record'
  spec.version       = LazyRecord::VERSION
  spec.authors       = ['M. Simon Borg']
  spec.email         = ['msimonborg@gmail.com']

  spec.summary       = 'Some ActiveRecord magic for your table-less POROs. WIP.'
  spec.description   = 'Add some convenience macros for your POROs that cut down on boilerplate code. Method definition macros, more powerful attr_accessors, and easy associations between in-memory objects. Somewhat mocks the ActiveRecord API to make it feel comfortable and intuitive for Rails developers. The main intent of this project is to explore dynamic programming in Ruby. Maybe someone will find it useful. WIP.'
  spec.homepage      = 'https://www.github.com/msimonborg/lazy_record'
  spec.license       = 'MIT'
  spec.add_dependency             'activesupport'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.required_ruby_version = '>= 2.1.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
