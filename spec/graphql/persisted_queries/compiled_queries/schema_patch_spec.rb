# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::SchemaPatch, compiled_queries_support: true do
  describe "inheritance" do
    let(:schema) { build_test_schema }

    let(:inherited_schema) { Class.new(schema) }

    describe "compiled_queries" do
      it "not sets up MultiplexPatch" do
        expect(inherited_schema.singleton_class).to include(
          GraphQL::PersistedQueries::SchemaPatch::MultiplexPatch
        )
      end

      context "when compiled_queries is set to true in parent schema" do
        let(:schema) do
          build_test_schema(compiled_queries: true)
        end

        it "not sets up MultiplexPatch" do
          expect(inherited_schema.singleton_class).not_to include(
            GraphQL::PersistedQueries::SchemaPatch::MultiplexPatch
          )
        end
      end
    end
  end
end
