# HTTPX vs Manticore

A trivial "benchmark" of Ruby HTTP clients [httpx] and [manticore]
against a simple echo server.

This test is JRuby only, because that's what I'm testing right now.

## Usage

```
$ rbenv local jruby-bla  # or equivalent
$ bundle install
$ cargo build --release
$ ./bench.sh
```

## Results

```
Environment: FreeBSD 13.2-RELEASE-p3 releng/13.2-n254633-a1c915cc75c1 GENERIC
 JRuby:      9.4.3.0
 JVM:        17.0.8+7-1
 JRUBY_OPTS: -J-Xmx16G -J-XX:+UseG1GC -J-XX:+UseStringDeduplication
 HTTPX:      1.0.2
 Manticore:  0.9.1

Test: echo of 96 bytes
 URI:      http://127.0.0.1:3000/echo
 Requests: 5000
--------------------------------------

Rehearsal ---------------------------------------------
httpx      28.234375   0.578125  28.812500 ( 10.974081)
manticore   2.914062   0.070312   2.984375 (  0.724888)
----------------------------------- total: 31.796875sec

                user     system      total        real
httpx      23.132812   0.328125  23.460938 ( 15.659571)
manticore   2.117188   0.062500   2.179688 (  0.427454)
```

[httpx]: https://rubygems.org/gems/httpx
[manticore]: https://rubygems.org/gems/manticore

