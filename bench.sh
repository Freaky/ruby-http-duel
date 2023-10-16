#!/bin/sh

cargo run --release &
bundle exec ruby bench.rb
kill %1
