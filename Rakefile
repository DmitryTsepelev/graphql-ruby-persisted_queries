require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]

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
