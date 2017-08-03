require "slanger/config"
require "slanger/api/server"
require "slanger/web_socket_server"

module Slanger
  module Service
    extend self

    def run
      Slanger::Config[:require].each { |f| require f }

      if Slanger::Config.statsd
        Slanger::Statsd.configure
      end

      Signal.trap('HUP') { stop }
      Signal.trap('INT') { stop }
      Signal.trap('QUIT') { stop }
      Signal.trap('TERM') { stop }

      Slanger::Api::Server.run
      Slanger::WebSocketServer.run
    end

    def stop
      puts "Stopping"

      Slanger::Api::Server.stop
      Slanger::WebSocketServer.stop

      EM.stop if EM.reactor_running?
    end
  end
end
