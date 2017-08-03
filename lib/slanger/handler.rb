# Handler class.
# Handles a client connected via a websocket connection.

require "active_support/core_ext/hash"
require "securerandom"
require "signature"
require "fiber"
require "rack"
require "oj"

module Slanger
  class Handler
    attr_accessor :connection
    delegate :send_error, :send_payload, :socket_id, to: :connection

    def initialize(socket)
      @socket        = socket
      @connection    = Connection.new(@socket)
      @subscriptions = {}
    end

    def onopen(handshake)
      @handshake = handshake
      authenticate
      Slanger::Statsd.increment("connections")
    end

    # Dispatches message handling to method with same name as
    # the event name
    def onmessage(msg)
      Slanger::Statsd.increment("messages")
      Slanger::Statsd.gauge("message_size", msg.bytesize)

      msg = Oj.load(msg)

      msg["data"] = Oj.load(msg["data"]) if msg["data"].is_a? String

      case msg["event"]
      when /\Aclient-/
        msg["socket_id"] = socket_id
        Channel.send_client_message(msg)
      when "pusher:ping"
        pusher_ping(msg)
      when "pusher:pong"
        pusher_pong(msg)
      when "pusher:subscribe"
        pusher_subscribe(msg)
      when "pusher:unsubscribe"
        pusher_unsubscribe(msg)
      end
    rescue JSON::ParserError, Oj::ParseError
      send_error({ code: 5001, message: "Invalid JSON" })
    rescue Exception => e
      puts "Error: #{e.class.name}: #{e.message}\n#{e.backtrace.join("\n")}"
      send_error({ code: 500, message: "Internal Error" })
    end

    def onclose(_)
      Slanger::Statsd.decrement("connections")

      subscriptions = @subscriptions.select { |k,v| k && v }

      subscriptions.each_key do |channel_id|
        subscription_id = subscriptions[channel_id]
        Channel.unsubscribe channel_id, subscription_id
      end
    end

    def authenticate
      if !valid_app_key? app_key
        send_error({ code: 4001, message: "Could not find app by key #{app_key}" })
        @socket.close_websocket
      elsif !valid_protocol_version?
        send_error({ code: 4007, message: "Unsupported protocol version" })
        @socket.close_websocket
      else
        send_payload(nil, "pusher:connection_established", {
          socket_id: socket_id,
          activity_timeout: Slanger::Config.activity_timeout,
        })
      end
    end

    def valid_protocol_version?
      protocol_version.between?(3, 7)
    end

    def pusher_ping(msg)
      send_payload nil, "pusher:pong"
    end

    def pusher_pong(msg)
    end

    def pusher_subscribe(msg)
      channel_id = msg["data"]["channel"]
      klass      = subscription_klass(channel_id)

      if @subscriptions[channel_id]
        send_error({ code: nil, message: "Existing subscription to #{channel_id}" })
      else
        @subscriptions[channel_id] = klass.new(@socket, socket_id, msg).subscribe
      end
    end

    def pusher_unsubscribe(msg)
      channel_id      = msg["data"]["channel"]
      subscription_id = @subscriptions.delete(channel_id)

      Channel.unsubscribe channel_id, subscription_id
    end

    private

    def app_key
      @handshake.path.split(/\W/)[2]
    end

    def protocol_version
      @query_string ||= Rack::Utils.parse_nested_query(@handshake.query_string)
      @query_string["protocol"].to_i || -1
    end

    def valid_app_key? app_key
      Slanger::Config.app_key == app_key
    end

    def subscription_klass(channel_id)
      case channel_id
      when /\Aprivate-/
        Slanger::PrivateSubscription
      when /\Apresence-/
        Slanger::PresenceSubscription
      else
        Slanger::Subscription
      end
    end
  end
end
