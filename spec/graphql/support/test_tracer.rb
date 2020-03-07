# frozen_string_literal: true

# TestTracer is used to collect events emitted through the tracing
# system for testing purposes only
class TestTracer
  attr_reader :events

  def initialize
    clear!
  end

  def trace(key, value)
    result = yield
    @events[key] << { metadata: value, result: result }
    result
  end

  def clear!
    @events = Hash.new { |hash, key| hash[key] = [] }
  end
end
