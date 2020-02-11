# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::BuilderHelpers do
  describe ".camelize" do
    let(:name) { nil }
    subject { described_class.camelize(name) }

    context "when a symbol is passed" do
      let(:name) { :this_is_a_test }

      it { is_expected.to eq("ThisIsATest") }
    end
  end
end
