# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'elastic_record'
  s.version = '0.6.1'
  s.summary = 'Use Elastic Search with your objects'
  s.description = 'Find your records with elastic search'

  s.required_ruby_version     = '>= 1.9.3'
  s.required_rubygems_version = ">= 1.8.11"
  s.license     = 'MIT'

  s.author            = 'Matthew Higgins'
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/matthuhiggins/elastic_record'

  s.extra_rdoc_files = ['README.rdoc']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test}/*`.split("\n")

  s.add_dependency 'arelastic'
  s.add_dependency 'activemodel'
end