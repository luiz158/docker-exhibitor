require 'rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: :test
desc 'Run syntax and spec tests.'
task test: [
  :rubocop,
  :spec
]
