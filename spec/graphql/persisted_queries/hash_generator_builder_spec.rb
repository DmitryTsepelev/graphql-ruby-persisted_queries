# frozen_string_literal: true

require "spec_helper"
require "digest"

RSpec.describe GraphQL::PersistedQueries::HashGeneratorBuilder do
  describe "#build" do
    let(:value) { "value" }

    subject { described_class.new(generator).build }

    context "when lambda is passed" do
      let(:generator) { proc { |value| "#{value}_hashed" } }

      it { is_expected.to be_kind_of(Proc) }

      it "uses generator" do
        expect(subject.call(value)).to eq("value_hashed")
      end

      context "when arity is different from 1" do
        let(:generator) { proc { |value1, value2| value1 + value2 } }

        it "raises error" do
          expect { subject }.to raise_error(
            ArgumentError,
            "proc passed to :hash_generator should have exactly one argument"
          )
        end
      end
    end

    context "when name is passed" do
      let(:generator) { :md5 }

      it { is_expected.to be_kind_of(Proc) }

      it "uses generator" do
        expect(subject.call(value)).to eq(Digest::MD5.hexdigest(value))
      end

      context "when digest not found" do
        let(:generator) { :unknown }

        it "raises error" do
          expect { subject }.to raise_error(
            NameError,
            "digest class for :#{generator} haven't been found"
          )
        end
      end
    end
  end
end
