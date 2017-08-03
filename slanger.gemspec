# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slanger/version'

Gem::Specification.new do |s|
  s.name                        = "slanger"
  s.version                     = Slanger::VERSION
  s.summary                     = "A websocket service compatible with Pusher libraries"
  s.description                 = "A websocket service compatible with Pusher libraries"
  s.files                       = Dir["README.md", "bin/*", "lib/**/*"]
  s.executables                 = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files                  = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths               = ["lib"]

  s.required_ruby_version       = ">= 2.0.0"

  s.authors                     = ["Stevie Graham", "Mark Burns"]
  s.email                       = ["sjtgraham@mac.com", "markthedeveloper@gmail.com"]
  s.homepage                    = "https://github.com/stevegraham/slanger"
  s.license                     = "MIT"

  s.add_dependency                "eventmachine",     "~> 1.0"
  s.add_dependency                "em-hiredis",       "~> 0.2"
  s.add_dependency                "em-http-request",  "~> 0.3"
  s.add_dependency                "em-websocket",     "~> 0.5"
  s.add_dependency                "rack",             "~> 1.4"
  s.add_dependency                "rack-fiber_pool",  "~> 0.9"
  s.add_dependency                "signature",        "~> 0.1"
  s.add_dependency                "activesupport",    "~> 4.2"
  s.add_dependency                "sinatra",          "~> 1.4"
  s.add_dependency                "thin",             "~> 1.6"
  s.add_dependency                "oj",               "~> 2.18"

  s.add_development_dependency    "rspec",            "~> 3.6"
  s.add_development_dependency    "pusher",           "~> 0.14"
  s.add_development_dependency    "haml",             "~> 3.1"
  s.add_development_dependency    "timecop",          "~> 0.3"
  s.add_development_dependency    "webmock",          "~> 1.8"
  s.add_development_dependency    "mocha",            "~> 0.13"
  s.add_development_dependency    "pry",              "~> 0.10"
  s.add_development_dependency    "pry-byebug",       "~> 2.0"
  s.add_development_dependency    "bundler",          "~> 1.5"
  s.add_development_dependency    "rake",             "~> 10.4"
  s.add_development_dependency    "statsd-ruby",      "~> 1.0"
end
