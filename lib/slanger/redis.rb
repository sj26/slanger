# Redis class.
# Interface with Redis.

require 'em-hiredis'
require 'oj'

module Slanger
  module Redis
    extend self

    def hgetall(*args)
      connection.hgetall(*args)
    end

    def hdel(*args)
      connection.hdel(*args)
    end

    def hset(*args)
      connection.hset(*args)
    end

    def hincrby(*args)
      connection.hincrby(*args)
    end

    def publish(*args)
      connection.publish(*args)
    end

    def subscribe(*args, &block)
      pubsub_connection.subscribe(*args, &block)
    end

    private

    def connection
      @connection ||= new_connection
    end

    def pubsub_connection
      @pubsub_connection ||= new_connection.pubsub.tap do |c|
        c.on(:message) do |channel, message|
          message = Oj.load(message)
          c = Channel.from message['channel']
          c.dispatch message, channel
        end
      end
    end

    private

    def new_connection
      EM::Hiredis.connect Slanger::Config.redis_address
    end
  end
end
