# frozen_string_literal: true

RSpec.describe Faraday::Adapter::HTTP do
  features :request_body_on_query_methods, :reason_phrase_parse, :trace_method, :connect_method,
           :skip_response_body_on_head, :local_socket_binding, :streaming

  it_behaves_like 'an adapter'

  # SSL options setting
  let(:adapter) { 'HTTP' }

  let(:conn_options) { { headers: { 'X-Faraday-Adapter' => adapter } } }

  let(:adapter_options) do
    []
  end

  let(:protocol) { 'https' }
  let(:remote) { "#{protocol}://example.com" }

  let(:conn) do
    conn_options[:ssl] ||= {}
    conn_options[:ssl][:ca_file] ||= ENV.fetch('SSL_FILE', nil)

    Faraday.new(remote, conn_options) do |conn|
      conn.request :url_encoded
      conn.response :raise_error
      conn.adapter described_class, *adapter_options
    end
  end

  context 'when handling errors' do
    it 'fails with a Faraday::SSL error for OpenSSL errors' do
      expect_any_instance_of(described_class).to receive(:setup_connection).and_raise('foo')
      stub_request(:get, 'https://example.com/')
        .with(
          headers: {
            'Connection' => 'close',
            'Host' => 'example.com',
            'User-Agent' => 'Agent Faraday',
            'X-Faraday-Adapter' => 'HTTP'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      expect do
        conn.get('/', nil, { user_agent: 'Agent Faraday' })
      end.to raise_error(StandardError, 'foo')
    end

    it 'fails with a Faraday::SSL error for OpenSSL errors' do
      expect_any_instance_of(
        described_class
      ).to receive(:setup_connection).and_raise(OpenSSL::SSL::SSLError, 'foo')
      stub_request(:get, 'https://example.com/')
        .with(
          headers: {
            'Connection' => 'close',
            'Host' => 'example.com',
            'User-Agent' => 'Agent Faraday',
            'X-Faraday-Adapter' => 'HTTP'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      expect do
        conn.get('/', nil, { user_agent: 'Agent Faraday' })
      end.to raise_error(Faraday::SSLError, 'foo')
    end
  end
end
