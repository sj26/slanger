require "slanger/config"

module Slanger
  module Statsd
    extend self

    def configure
      begin
        require "statsd"
      rescue LoadError
        puts "Couldn't load the statsd gem:"
        puts
        puts "  #{$!}"
        puts
        puts "Please install the statsd gem for statsd support:"
        puts
        puts "  gem install statds"
        puts
        exit 1
      end

      @statsd = ::Statsd.new(Slanger::Config.statsd_host, Slanger::Config.statsd_port)
      @statsd.namespace = Slanger::Config.statsd_namespace if Slanger::Config.statsd_namespace
    end

    def enabled?
      Slanger::Config.statsd
    end

    def increment(*args)
      @statsd.increment(*args) if enabled?
    end

    def decrement(*args)
      @statsd.decrement(*args) if enabled?
    end

    def count(*args)
      @statsd.count(*args) if enabled?
    end

    def gauge(*args)
      @statsd.gauge(*args) if enabled?
    end

    def flush
      @statsd.flush if enabled?
    end
  end
end
