#!/bin/bash

set -e
set -x

# Before running this script, run `MYSQL_VERSION=8.0 docker-compose up -d vtgate`

bundle exec rake clean
bundle exec rake compile
ruby -I lib -r trilogy test-vtgate-ssl-error.rb
