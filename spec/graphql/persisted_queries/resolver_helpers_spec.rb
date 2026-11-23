# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::ResolverHelpers do
  it "keeps Module#hash, so the module can be a hash key" do
    modules = { described_class => :resolver_helpers }

    expect(modules[described_class]).to eq(:resolver_helpers)
  end

  it "keeps Object#hash on a resolver, so the resolver can be a hash key" do
    resolver = GraphQL::PersistedQueries::Resolver.new({}, double("TestSchema"))
    resolvers = { resolver => :resolver }

    expect(resolvers[resolver]).to eq(:resolver)
  end
end
