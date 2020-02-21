# frozen_string_literal: true

require "spec_helper"
require "dalli"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::MemcachedClientBuilder do
  describe "#initialize" do
    let(:options) { {} }

    subject { described_class.new(options).build }

    context "when memcached_host, memcached_port and memcached_db_name are passed" do
      let(:options) do
        { memcached_host: "127.0.0.2", memcached_port: "11211" }
      end

      it "builds memcached URL" do
        expect(::Dalli::Client).to receive(:new).with("127.0.0.2:11211",
                                                      compress: true, pool_size: 5)
        subject
      end
    end

    context "when memcached_url is passed" do
      let(:options) { { memcached_url: "127.0.0.4:11211" } }

      it "uses passed memcached_url" do
        expect(::Dalli::Client).to receive(:new).with("127.0.0.4:11211",
                                                      compress: true, pool_size: 5)
        subject
      end

      context "when passed along with other parameters" do
        let(:options) do
          {
            memcached_url: "127.0.0.1:11211",
            memcached_host: "127.0.0.1",
            memcached_port: "11211"
          }
        end

        it "raises error" do
          expect { subject }.to raise_error(
            ArgumentError,
            "memcached_url cannot be passed along with memcached_host or memcached_port options"
          )
        end
      end
    end
  end
end
