# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zippo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jonathon M. Abbott"]
  gem.email         = ["jma@dandaraga.net"]
  gem.summary       = 'An (almost) pure-ruby Zip library'
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/JonathonMA/zippo"
  gem.license       = "MIT"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "zippo"
  gem.require_paths = ["lib"]
  gem.version       = Zippo::VERSION

  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "yard", '>= 0.8'
  gem.add_development_dependency "redcarpet"
end
