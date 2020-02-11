# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::ErrorHandlers::DefaultErrorHandler do
  let(:options) { {} }
  subject { described_class.new(options) }

  describe "#call" do
    context "when passed an error" do
      it "raises the error" do
        error = StandardError.new
        expect { subject.call(error) }.to raise_error(error)
      end
    end
  end
end
