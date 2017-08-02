require 'eventmachine'
require 'em-websocket'

module Slanger
  module WebSocketServer
    extend self

    def run
      options = {
        host:    Slanger::Config[:websocket_host],
        port:    Slanger::Config[:websocket_port],
        debug:   Slanger::Config[:debug],
        app_key: Slanger::Config[:app_key]
      }

      if Slanger::Config[:tls_options]
        options.merge! secure: true,
                       tls_options: Slanger::Config[:tls_options]
      end

      EM::WebSocket.run(options) do |connection|
        # Keep track of handler instance in instance of EM::Connection to ensure a unique handler instance is used per connection.
        connection.class_eval { attr_accessor :connection_handler }
        # Delegate connection management to handler instance.
        connection.onopen { |handshake| connection.connection_handler = Slanger::Config.socket_handler.new connection, handshake }
        connection.onmessage { |msg| connection.connection_handler.onmessage msg }
        connection.onclose { connection.connection_handler.onclose }
      end
    end

    def stop
      EM::WebSocket.stop
    end
  end
end
