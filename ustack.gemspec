# coding: utf-8

$:.push File.expand_path('../lib', __FILE__)

require 'ustack/version'

Gem::Specification.new do |gem|
  gem.name = 'ustack'
  gem.version = Ustack::VERSION
  gem.description = 'Micro middleware stack for general purpose'
  gem.summary = gem.description
  gem.homepage = 'https://github.com/kostia/ustack'
  gem.authors = ['Kostiantyn Kahanskyi']
  gem.email = %w[kostiantyn.kahanskyi@googlemail.com]
  gem.files = Dir['lib/**/*'] + %w[Rakefile README.md]
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
