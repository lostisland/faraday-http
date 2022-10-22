# frozen_string_literal: true

require 'http'

module Faraday
  class Adapter
    # HTTP.rb adapter.
    class HTTP < Faraday::Adapter
      # Takes the environment and performs the request.
      #
      # @param env [Faraday::Env] the request environment.
      #
      # @return [Faraday::Response] the response.
      def call(env)
        super
        perform_request(env)
        @app.call(env)
      end

      private

      def perform_request(env)
        connection = setup_connection(env)

        response = connection.request env[:method], env[:url],
                                      body: env[:body],
                                      ssl_context: ssl_context(env[:ssl])

        if env.stream_response?
          env.stream_response do |&on_data|
            request_with_wrapped_block(response, env, &on_data)
          end
          body = ''
        else
          body = response.body.to_s
        end

        save_response(env, response.code, body, response.headers, response.status.reason)
      rescue ::HTTP::TimeoutError
        raise Faraday::TimeoutError, $ERROR_INFO
      rescue ::HTTP::ConnectionError
        raise Faraday::ConnectionFailed, $ERROR_INFO
      rescue StandardError => e
        raise Faraday::SSLError, e if defined?(OpenSSL) && e.is_a?(OpenSSL::SSL::SSLError)

        raise
      end

      def request_with_wrapped_block(response, env)
        return unless block_given?

        while (chunk = response.body.readpartial)
          yield(chunk, env)
        end
      end

      def setup_connection(env)
        conn = ::HTTP

        conn = request_config(conn, env[:request]) if env[:request]
        conn.headers(env.request_headers)
      end

      def request_config(conn, config)
        if (timeout = config[:timeout])
          conn = conn.timeout(timeout)
        end

        if (timeout = config[:open_timeout])
          conn = conn.timeout(connect: timeout, write: timeout)
        end

        if (proxy = config[:proxy])
          conn = conn.via(proxy.uri.host, proxy.uri.port, proxy.user, proxy.password)
        end

        conn
      end

      def ssl_context(ssl)
        params = {}
        %i[
          ca_file ca_path cert_store verify_depth
        ].each do |key|
          if (value = ssl[key])
            params[key] = value
          end
        end

        if (client_cert = ssl_client_cert(ssl.client_cert))
          params[:cert] = client_cert
        end

        if (client_key = ssl_client_key(ssl.client_key))
          params[:key] = client_key
        end

        OpenSSL::SSL::SSLContext.new.tap do |ctx|
          ctx.set_params(params)
          if (vm = ssl.verify_mode)
            ctx.verify_mode = vm
          elsif ssl.disable?
            ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          if (v = ssl.version)
            ctx.ssl_version = v
          end

          if ctx.respond_to?(:min_version=) && (v = ssl.min_version)
            ctx.min_version = v
          end
        end
      end

      def ssl_client_cert(cert)
        return nil if cert.nil?
        return OpenSSL::X509::Certificate.new(File.read(cert)) if cert.is_a(String)
        return cert if cert.is_a?(OpenSSL::X509::Certificate)

        raise Faraday::Error, "invalid ssl.client_cert: #{cert.inspect}"
      end

      def ssl_client_key(cert)
        return nil if cert.nil?
        return OpenSSL::PKey::RSA.new(File.read(cert)) if cert.is_a(String)
        return cert if cert.is_a?(OpenSSL::PKey::RSA, OpenSSL::PKey::DSA)

        raise Faraday::Error, "invalid ssl.client_key: #{cert.inspect}"
      end
    end
  end
end
