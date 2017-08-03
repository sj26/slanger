require "oj"
require "securerandom"

require "slanger/config"

module Slanger
  class Connection
    attr_accessor :socket, :socket_id

    def initialize(socket, socket_id = nil)
      @socket = socket
      @socket_id = socket_id || "%d.%d" % [Process.pid, SecureRandom.random_number(10 ** 6)]
    end

    def send_message(serialized_message)
      message = Oj.load(serialized_message)

      from_socket_id = message.delete("socket_id")

      if from_socket_id.nil? || from_socket_id != socket_id
        reserialized_message = serialize(message)

        Slanger::Statsd.increment("messages")
        Slanger::Statsd.gauge("message_size", reserialized_message.bytesize)
        socket.send(reserialized_message)
      end
    end

    def send_payload(channel_id, event_name, payload = {})
      message = {
        event: event_name,
        data: serialize(payload),
      }
      message[:channel] = channel_id if channel_id

      serialized_message = serialize(message)

      Slanger::Statsd.increment("messages")
      Slanger::Statsd.gauge("message_size", serialized_message.bytesize)
      socket.send(serialized_message)
    end

    def send_error(message)
      begin
        send_payload(nil, "pusher:error", message)
      rescue EventMachine::WebSocket::WebSocketError
        # Raised if connecection already closed. Only seen with Thor load testing tool
      end
    end

    private

    def serialize(data)
      Oj.dump(data, mode: :compat)
    end
  end
end
