#!/bin/sh
#bundle install
if [ "$1" = "irb" ]; then
  bundle exec irb -Ilib -r postgresql_cursor
elif [ "$1" = "setup" ]; then
  createdb postgresql_cursor_test
  echo "create table products ( id serial);" | psql postgresql_cursor_test
else
  bundle exec ruby app.rb
fi
