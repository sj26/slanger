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
        handler = Slanger::Config.socket_handler.new(connection)

        connection.onopen(&handler.method(:onopen))
        connection.onmessage(&handler.method(:onmessage))
        connection.onclose(&handler.method(:onclose))
      end
    end

    def stop
      EM::WebSocket.stop
    end
  end
end
