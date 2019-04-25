# frozen_string_literal: true

module Faraday
  class Adapter
    # HTTP.rb adapter.
    class HTTP < Faraday::Adapter
      dependency 'http'

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
        conn = setup_connection(env)

        resp = conn.request env[:method], env[:url],
          body: env[:body],
          ssl_context: ssl_context(env[:ssl])

        save_response(env, resp.code, resp.body.to_s, resp.headers, resp.status.reason)
      rescue ::HTTP::TimeoutError
        raise Faraday::TimeoutError, $ERROR_INFO
      rescue ::HTTP::ConnectionError
        raise Faraday::ConnectionFailed, $ERROR_INFO
      rescue StandardError => e
        raise Faraday::SSLError, e if defined?(OpenSSL) && e.is_a?(OpenSSL::SSL::SSLError)

        raise
      end

      def setup_connection(env)
        conn = ::HTTP

        request_config(conn, env[:request]) if env[:request]
        conn.headers(env.request_headers)
      end

      def request_config(conn, config)
        if (timeout = config[:timeout])
          conn = conn.timeout(connect: timeout, read: timeout, write: timeout)
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
        [
          :ca_file, :ca_path, :cert_store, :verify_depth,
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
        case cert
        when NilClass then return
        when String
          return OpenSSL::X509::Certificate.new(File.read(cert))
        when OpenSSL::X509::Certificate
          return cert
        else
          raise Faraday::Error, "invalid ssl.client_cert: #{cert.inspect}"
        end
      end

      def ssl_client_key(cert)
        case cert
        when NilClass then return
        when String
          return OpenSSL::PKey::RSA.new(File.read(cert))
        when OpenSSL::PKey::RSA, OpenSSL::PKey::DSA
          return cert
        else
          raise Faraday::Error, "invalid ssl.client_key: #{cert.inspect}"
        end
      end
    end
  end
end
