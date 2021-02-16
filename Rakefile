require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc "Run specs for compiled queries"
RSpec::Core::RakeTask.new("spec:compiled_queries") do |task|
  task.pattern = "**/compiled_queries/**"
  task.verbose = false
end

RSpec::Core::RakeTask.new("spec:without_compiled_queries") do |task|
  task.exclude_pattern = "**/compiled_queries/**"
  task.verbose = false
end

task ci_specs: ["spec:without_compiled_queries", "spec:compiled_queries"]

task :bench_gql do
  cmd = %w[bundle exec ruby benchmark/plain_gql.rb]
  system(*cmd)
end

task :bench_pq do
  cmd = %w[bundle exec ruby benchmark/persisted_queries.rb]
  system(*cmd)
end

task :bench_compiled do
  cmd = %w[bundle exec ruby benchmark/compiled_queries.rb]
  system(*cmd)
end

task bench: [:bench_gql, :bench_pq, :bench_compiled]
