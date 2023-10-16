#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'httpx'

manticore = false

begin
  require 'manticore'
  manticore = Manticore::Client.new
rescue LoadError
end

curb = false
begin
  require 'curb'
  curl = Curl
rescue LoadError
end

uri = 'http://127.0.0.1:3000/echo'
runs = 5000
query = <<EOC
{
  "track_total_hits" : false,
  "from" : 0,
  "sort" : [ {
    "commit_date" : "desc"
  } ]
}
EOC

headers = {
  'User-Agent' => 'elasticsearch-ruby/8.10.0; elastic-transport-ruby/8.3.0; RUBY_VERSION: 3.1.4;',
  'Content-Type' => 'application/json',
}.freeze

puts "Environment: #{`uname -v`.chomp}"

if RUBY_PLATFORM == 'java'
puts <<EOC
 JRuby:      #{JRUBY_VERSION}
 JVM:        #{ENV_JAVA['java.runtime.version']}
 JRUBY_OPTS: #{ENV['JRUBY_OPTS']}
 Manticore:  #{Manticore::VERSION}
EOC
else
  puts <<EOC
 Ruby:       #{RUBY_VERSION}
 Curb:       #{Curl::VERSION}
EOC
end

puts <<EOC
 HTTPX:      #{HTTPX::VERSION}
 Test: echo of #{query.bytesize} bytes
 URI:      #{uri}
 Requests: #{runs}
--------------------------------------

EOC

httpx = HTTPX.with(headers: headers)

Benchmark.bmbm do |x|
  x.report('httpx') do
    runs.times do
      raise "Mismatch" if httpx.post(uri, body: query).to_s != query
    end
  end

  x.report('manticore') do
    runs.times do
      manticore.post(uri, headers: headers, body: query) do |response|
        raise "Mismatch" if response.read_body != query
      end
    end
  end if manticore

  x.report('curb') do
    runs.times do
      raise "Mismatch" if (curl.post(uri, query) do |request|
        request.headers = headers
      end.body != query)
    end
  end if curl
end

