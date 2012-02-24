# -*- encoding: utf-8 -*-
require File.expand_path('../lib/radian6/version', __FILE__)

Gem::Specification.new do |s|
  s.add_development_dependency('rake', '~> 0.8')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('yard')
  s.add_development_dependency('webmock')
  s.add_runtime_dependency('nokogiri', '>= 1.4.4')
  s.add_runtime_dependency('em-http-request')
  s.authors = ["Riccardo Cambiassi"]
  s.description = %q{A Ruby wrapper for the Radian6 REST API}
  s.post_install_message =<<eos
********************************************************************************

  Thank you for installing radian6

  Follow @bru on Twitter for announcements, updates, and news.
  https://twitter.com/bru

********************************************************************************
eos
  s.email = ['bru@codewitch.org']
  # s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/bru/radian6'
  s.name = 'radian6'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=
  s.rubyforge_project = s.name
  s.summary = %q{Ruby wrapper for the Radian6 API}
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Radian6::VERSION.dup
end
