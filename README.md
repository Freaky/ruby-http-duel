# HTTPX vs Manticore/Curb

A trivial "benchmark" of Ruby HTTP clients [httpx] and [manticore] (JRuby)
or [curb] (MRI) against a simple echo server.

## Usage

```
$ bundle install
$ cargo build --release
$ ./bench.sh
```

## Results

### JRuby

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

### Ruby 3.3.0-preview2

#### Interpreted

```
Environment: FreeBSD 13.2-RELEASE-p3 releng/13.2-n254633-a1c915cc75c1 GENERIC
 Ruby:       3.3.0
 Curb:       8.4.0
 HTTPX:      1.0.2
 Test: echo of 96 bytes
 URI:      http://127.0.0.1:3000/echo
 Requests: 5000
--------------------------------------

Rehearsal -----------------------------------------
httpx   5.092907   0.103471   5.196378 (  5.201477)
curb    0.148671   0.040084   0.188755 (  0.216876)
-------------------------------- total: 5.385133sec

            user     system      total        real
httpx  11.811634   0.078473  11.890107 ( 11.917484)
curb    0.153671   0.015715   0.169386 (  0.197445)
```

#### YJIT

```
Rehearsal -----------------------------------------
httpx   3.125992   0.109961   3.235953 (  3.241366)
curb    0.134511   0.039316   0.173827 (  0.201959)
-------------------------------- total: 3.409780sec

user     system      total        real
httpx   7.082681   0.094486   7.177167 (  7.185236)
curb    0.120101   0.047045   0.167146 (  0.196331)
```

Something odd going on with httpx times, it's consistently better during warmup?

[httpx]: https://rubygems.org/gems/httpx
[manticore]: https://rubygems.org/gems/manticore
[curb]: https://rubygems.org/gems/curb

