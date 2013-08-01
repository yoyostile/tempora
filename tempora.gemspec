$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tempora/version"

rails_version = ENV["RAILS_VERSION"] || "default"
rails = case rails_version
when "default"
  ">= 3.1.2"
else
  "~> #{rails_version}"
end

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tempora"
  s.version     = Tempora::VERSION
  s.authors     = ["Johannes Heck"]
  s.email       = ["yoyostile@gmail.com"]
  s.homepage    = "https://github.com/yoyostile/tempora"
  s.summary     = "Tempora is an implict collaborative recommender system"
  s.description = "Tempora is an implict collaborative recommender system"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", rails
  s.add_dependency 'redis', '>= 2.2.0'

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
end
