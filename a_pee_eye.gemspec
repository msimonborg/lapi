# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'a_pee_eye/version'

Gem::Specification.new do |spec|
  spec.name          = 'a_pee_eye'
  spec.version       = APeeEye::VERSION
  spec.authors       = ['M. Simon Borg']
  spec.email         = ['msimonborg@gmail.com']

  spec.summary       = 'Extensible library for interfacing with external APIs'
  spec.description   = 'Extensible library for interfacing with external APIs'
  spec.homepage      = 'https://www.github.com/msimonborg/a_pee_eye'
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

  spec.add_dependency 'lazy_record', '~> 0.2.0'
  spec.add_dependency 'httparty'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
