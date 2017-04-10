# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'lapi'
  spec.version       = LAPI::VERSION
  spec.authors       = ['M. Simon Borg']
  spec.email         = ['msimonborg@gmail.com']

  spec.summary       = 'Extensible and configurable library for interfacing with external REST APIs.'
  spec.description   = 'Set up a pure ruby interface to an external API in one easy configuration file.'\
    ' Abstract away the URI\'s, params, HTTP requests, and JSON data structures, replacing it with'\
    ' Ruby block syntax, custom objects, method calls, scopes, and object associations. One configuration block'\
    ' creates all the classes and methods that you need, saving you from writing files and files of'\
    ' boilerplate code.'
  spec.homepage      = 'https://www.github.com/msimonborg/lapi'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes
  # either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
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

  spec.add_dependency 'lazy_record', '~> 0.3', '>= 0.3.0'
  spec.add_dependency 'httparty'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
