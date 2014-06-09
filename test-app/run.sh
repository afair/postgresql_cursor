#!/bin/sh
#bundle install
if [ "$1" = "irb" ]; then
  bundle exec irb -Ilib -r postgresql_cursor
else
  bundle exec ruby app.rb
fi
