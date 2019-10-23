lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql/persisted_queries/version"

Gem::Specification.new do |spec|
  spec.name          = "graphql-persisted_queries"
  spec.version       = GraphQL::PersistedQueries::VERSION
  spec.authors       = ["DmitryTsepelev"]
  spec.email         = ["dmitry.a.tsepelev@gmail.com"]

  spec.summary       = "Persisted queries for graphql-ruby"
  spec.description   = "Persisted queries for graphql-ruby"
  spec.homepage      = "https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "graphql", ">= 1.8"

  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rubocop", "0.75"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "connection_pool"
end
