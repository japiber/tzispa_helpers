# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tzispa/helpers/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = Tzispa::Helpers::GEM_NAME
  s.version     = Tzispa::Helpers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Juan Antonio Piñero']
  s.email       = ['japinero@area-integral.com']
  s.homepage    = 'https://github.com/japiber/tzispa_helpers.git'
  s.summary     = 'Helpers for Tzispa'
  s.description = 'Module Helpers for Tzispa framework'
  s.licenses    = ['MIT']

  s.required_ruby_version     = '~> 2.3'

  s.add_dependency 'mail',               '~> 2.6'
  s.add_dependency 'i18n',               '~> 0.7'
  s.add_dependency 'unicode_utils',      '~> 1.4'
  s.add_dependency 'reverse_markdown',   '~> 1.0'
  s.add_dependency 'redcarpet',          '~> 3.3'
  s.add_dependency 'nokogiri',           '~> 1.6'

  s.files         = Dir.glob("{lib}/**/*") + %w(README.md CHANGELOG.md)
  s.require_paths = ['lib']
end
