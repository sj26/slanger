require "rack"
require "thin"

require "slanger/config"
require "slanger/api/application"

module Slanger::Api
  module Server
    extend self

    def run
      Thin::Logging.silent = true unless Slanger::Config[:debug]

      Rack::Handler.get('thin').run(Slanger::Api::Application, Host: Slanger::Config[:api_host], Port: Slanger::Config[:api_port], signals: false) do |server|
        @server = server
        if Slanger::Config[:tls_options]
          @server.ssl = true
          @server.ssl_options = Slanger::Config[:tls_options]
        end
      end
    end

    def stop
      @server.stop
    end
  end
end
