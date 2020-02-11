# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::ErrorHandlers do
  describe ".build" do
    let(:options) { nil }
    subject { described_class.build(handler, options) }

    context "when ErrorHandlers::BaseErrorHandler instance is passed" do
      let(:handler) do
        GraphQL::PersistedQueries::ErrorHandlers::BaseErrorHandler.new(options)
      end

      it { is_expected.to be(handler) }
    end

    context "when proc is passed" do
      let(:handler) do
        ->(error) { raise error }
      end

      it { is_expected.to be(handler) }

      context "with wrong number of arguments" do
        let(:handler) do
          ->(error, more) { raise error, more }
        end

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    context "when name is passed" do
      let(:handler) { :default }

      it { is_expected.to be_a(GraphQL::PersistedQueries::ErrorHandlers::DefaultErrorHandler) }

      context "when handler is not found" do
        let(:handler) { :unknown }

        it "raises error" do
          expect { subject }.to raise_error(
            NameError,
            "Persisted query error handler for :#{handler} haven't been found"
          )
        end
      end
    end
  end
end
