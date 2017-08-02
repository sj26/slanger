# encoding: utf-8

require 'eventmachine'
require 'em-hiredis'
require 'rack'

require 'slanger/version'

module Slanger; end

case
when EM.epoll?  then EM.epoll
when EM.kqueue? then EM.kqueue
end

require 'slanger/api'
require 'slanger/api/event'
require 'slanger/api/event_publisher'
require 'slanger/api/request_validation'
require 'slanger/api/server'
require 'slanger/channel'
require 'slanger/config'
require 'slanger/connection'
require 'slanger/handler'
require 'slanger/logger'
require 'slanger/presence_channel'
require 'slanger/presence_subscription'
require 'slanger/private_subscription'
require 'slanger/redis'
require 'slanger/service'
require 'slanger/subscription'
require 'slanger/version'
require 'slanger/web_socket_server'
require 'slanger/webhook'