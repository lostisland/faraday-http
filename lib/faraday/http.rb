# frozen_string_literal: true

require 'faraday'
require 'faraday/http/version'
require 'faraday/adapter/http'

# Extend the main Faraday module.
module Faraday
  module Http
    class Error < StandardError; end
  end

  Faraday::Adapter.register_middleware(http: Faraday::Adapter::HTTP)
end
