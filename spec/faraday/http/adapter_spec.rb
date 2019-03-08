# frozen_string_literal: true

RSpec.describe Faraday::Http::Adapter do
  features :request_body_on_query_methods, :reason_phrase_parse, :trace_method, :connect_method,
           :skip_response_body_on_head, :local_socket_binding

  it_behaves_like 'an adapter'
end
