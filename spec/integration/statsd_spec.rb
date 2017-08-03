require "spec_helper"

describe "Integration" do
  describe "Slanger when configured to use Statsd" do
    it "sends stats to configured address" do
      stats = []
      stats_thread = Thread.new do 
        socket = UDPSocket.new
        socket.bind(Slanger::Config[:statsd_host], Slanger::Config[:statsd_port])
        while data = socket.recvfrom(512)[0]
          stats.concat(data.split("\n"))
        end
      end

      start_slanger_with_options statsd: true

      em_stream do |client, messages|
        case messages.length
        when 1
          client.send({event: "pusher:subscribe", data: {channel: "MY_CHANNEL"}}.to_json)
        when 2
          Pusher["MY_CHANNEL"].trigger("test", {"foo" => "bar"})
        when 3
          # Stop the event loop once websocket disconnects and after the
          # ondisconnect has a chance to run
          client.disconnect { EM::Timer.new(0.1) { EM.stop } }
          client.close_connection_after_writing
        end
      end

      Slanger::Statsd.flush

      stats_thread.kill
      stats_thread.join

      expect(stats).to include("slanger.connections:1|c")
      expect(stats).to include("slanger.messages:1|c")
      expect(stats).to include(/slanger\.message_size:\d+|c/)
      expect(stats).to include("slanger.connections:-1|c")
    end
  end
end
