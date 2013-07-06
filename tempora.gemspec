$:.push File.expand_path("../lib", __FILE__)
require "tempora/version"

Gem::Specification.new do |s|
  s.name        = 'tempora'
  s.version     = Tempora::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'fantastic collaborative filtering'
  s.description = 'Tempora is an implicit collaborative recommender system'
  s.authors     = ["Johannes Heck"]
  s.email       = 'yoyostile@gmail.com'
  s.files       = ["lib/tempora.rb"]
  s.homepage    = 'https://github.com/yoyostile/tempora'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
