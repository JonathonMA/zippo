#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

require './yard_extensions'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

YARD::Rake::YardocTask.new

task default: [
  :spec,
  :rubocop,
]
