# frozen_string_literal: true

require "graphql"
require "graphql/persisted_queries"
require "graphql/support/test_schema"
require "graphql/support/test_tracer"

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  config.order = :random

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.formatter = :documentation
  config.color = true
end
