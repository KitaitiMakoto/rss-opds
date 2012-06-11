# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rss/opds/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = ["KitaitiMakoto@gmail.com"]
  gem.description   = %q{OPDS parser and maker}
  gem.summary       = %q{This gem extends Ruby bundled RSS library to parse and make OPDS catalogs}
  gem.homepage      = "https://gitorious.org/rss/opds"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rss-opds"
  gem.require_paths = ["lib"]
  gem.version       = RSS::OPDS::VERSION

  gem.add_runtime_dependency 'rss-dcterms'
  gem.add_runtime_dependency 'rss-atom-feed_history'

  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-doc'
end
