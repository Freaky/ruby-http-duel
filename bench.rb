#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'httpx'

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

httpx = HTTPX

manticore = begin
  require 'manticore'
  Manticore::Client.new(keepalive: false)
rescue LoadError
end

curl = begin
  require 'curb'
  Curl::Easy.new do |c|
    c.setopt(Curl::CURLOPT_FORBID_REUSE, 1)
  end
rescue LoadError
end

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

Benchmark.bmbm do |x|
  x.report('httpx') do
    runs.times do
      raise "Mismatch" if httpx.post(uri, headers: headers, body: query).to_s != query
    end
  end if httpx

  x.report('manticore') do
    runs.times do
      manticore.post(uri, headers: headers, body: query) do |response|
        raise "Mismatch" if response.read_body != query
      end
    end
  end if manticore

  x.report('curb') do
    runs.times do
      curl.url = uri
      curl.headers = headers
      curl.http_post(query)
      raise "Mismatch" if curl.body_str != query
    end
  end if curl
end while true

