# frozen_string_literal: true

require 'faraday'
require 'faraday/http/version'
require 'faraday/adapter/http'

module Faraday
  module Http
    class Error < StandardError; end
    # Your code goes here...
  end

  Faraday::Adapter.register_middleware http: Faraday::Adapter::HTTP
end
