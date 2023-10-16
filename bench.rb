#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'httpx'
require 'manticore'

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

puts <<EOC
Environment: #{`uname -v`.chomp}
 JRuby:      #{JRUBY_VERSION}
 JVM:        #{ENV_JAVA['java.runtime.version']}
 JRUBY_OPTS: #{ENV['JRUBY_OPTS']}
 HTTPX:      #{HTTPX::VERSION}
 Manticore:  #{Manticore::VERSION}

Test: echo of #{query.bytesize} bytes
 URI:      #{uri}
 Requests: #{runs}
--------------------------------------

EOC

manticore = Manticore::Client.new
httpx = HTTPX.with(headers: headers)

bytes_manticore = 0
bytes_httpx = 0
bytes_expected = query.bytesize * runs * 2

Benchmark.bmbm do |x|
  x.report('httpx') do
    runs.times do
      bytes_httpx += httpx.post(uri, body: query).to_s.bytesize
    end
  end

  x.report('manticore') do
    runs.times do
      manticore.post(uri, headers: headers, body: query) do |response|
        bytes_manticore += response.read_body.bytesize
      end
    end
	end
end

def assert_bytes(server, expected, actual)
  warn "#{server}: #{expected} != #{actual} bytes" unless expected == actual
end

at_exit do
  assert_bytes("manticore", bytes_expected, bytes_manticore)
  assert_bytes("httpx", bytes_expected, bytes_httpx)
end

