# frozen_string_literal: true

require "spec_helper"

require "dalli"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::MemcachedStoreAdapter do
  subject { described_class.new(**options) }

  let(:expiration) { nil }
  let(:namespace) { nil }
  let(:options) do
    {
      dalli_client: dalli_client,
      expiration: expiration,
      namespace: namespace
    }
  end

  context "when Hash instance is passed" do
    let(:dalli_client) { { memcached_url: "127.0.0.3:11211" } }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@dalli_proc")).to be_kind_of(Proc)
    end
  end

  context "when Proc instance is passed" do
    let(:dalli_client) { proc {} }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@dalli_proc")).to be_kind_of(Proc)
    end
  end

  context "when Dalli::Client instance is passed" do
    let(:dalli_client) { Dalli::Client.new("127.0.0.3:11211") }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@dalli_proc")).to be_kind_of(Proc)
    end
  end

  context "when expiration is not passed" do
    let(:dalli_client) { proc {} }

    it "falls back to the default expiration" do
      expect(subject.instance_variable_get("@expiration")).to eq(86400)
    end
  end

  context "when expiration is passed" do
    let(:dalli_client) { proc {} }
    let(:expiration) { 1_000_000 }

    it "uses the passed expiration" do
      expect(subject.instance_variable_get("@expiration")).to eq(expiration)
    end
  end

  context "when namespace is not passed" do
    let(:dalli_client) { proc {} }

    it "falls back to the default namespace" do
      expect(subject.instance_variable_get("@namespace")).to eq("graphql-persisted-query")
    end
  end

  context "when namespace is passed" do
    let(:dalli_client) { proc {} }
    let(:namespace) { "my-very-own-namespace" }

    it "uses the passed namespace" do
      expect(subject.instance_variable_get("@namespace")).to eq(namespace)
    end
  end

  context "when not supported object is passed" do
    let(:dalli_client) { 42 }

    it "raises error" do
      expect { subject }.to raise_error(
        ArgumentError,
        ":dalli_client accepts Dalli::Client, Hash or Proc only"
      )
    end
  end

  describe "interaction with underlying client" do
    let(:key) { "key" }
    let(:value) { "value" }

    let(:dalli_client) { proc { |&block| block.call(dalli_client_stub) } }
    let(:dalli_client_stub) { instance_double(Dalli::Client, set: true, get: Marshal.dump(value)) }

    specify do
      subject.save(key, value)

      expect(dalli_client_stub).to have_received(:set).once
      expect(subject.fetch(key)).to eq(value)
      expect(dalli_client_stub).to have_received(:get).with(end_with(key)).once
    end
  end
end
