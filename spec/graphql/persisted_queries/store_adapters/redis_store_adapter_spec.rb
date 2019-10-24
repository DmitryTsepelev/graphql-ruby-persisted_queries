# frozen_string_literal: true

require "spec_helper"

require "redis"
require "connection_pool"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::RedisStoreAdapter do
  subject { described_class.new(redis_client: redis_client) }

  context "when Hash instance is passed" do
    let(:redis_client) { { redis_url: "redis://127.0.0.3:8791/3" } }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@redis_proc")).to be_kind_of(Proc)
    end
  end

  context "when Proc instance is passed" do
    let(:redis_client) { proc {} }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@redis_proc")).to be_kind_of(Proc)
    end
  end

  context "when Redis instance is passed" do
    let(:redis_client) { Redis.new(url: "redis://127.0.0.3:8791/3") }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@redis_proc")).to be_kind_of(Proc)
    end
  end

  context "when ConnectionPool instance is passed" do
    let(:redis_client) { ConnectionPool.new { Redis.new(url: "redis://127.0.0.3:8791/3") } }

    it "wraps with proc" do
      expect(subject.instance_variable_get("@redis_proc")).to be_kind_of(Proc)
    end
  end

  context "when not supported object is passed" do
    let(:redis_client) { 42 }

    it "raises error" do
      expect { subject }.to raise_error(
        ArgumentError,
        ":redis_client accepts Redis, ConnectionPool, Hash or Proc only"
      )
    end
  end
end
