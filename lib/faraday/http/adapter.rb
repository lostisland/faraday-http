# frozen_string_literal: true

module Faraday
  module Http
    # HTTP.rb adapter.
    class Adapter < Faraday::Adapter
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
        conn = setup_connetion(env)

        resp = conn.request env[:method], env[:url], body: env[:body]
        save_response(env, resp.code, resp.body.to_s, resp.headers, resp.status.reason)
      rescue ::HTTP::TimeoutError
        raise Faraday::TimeoutError, $ERROR_INFO
      rescue ::HTTP::ConnectionError
        raise Faraday::ConnectionFailed, $ERROR_INFO
      end

      def setup_connetion(env)
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
    end
  end
end
