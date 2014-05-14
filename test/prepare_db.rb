require 'rubygems'
require 'bundler/setup'
require 'active_record'

db_user = ENV['TEST_DB_USER'] || `whoami`.chomp
db_name = ENV['TEST_DB_USER'] || 'postgresql_cursor_test'
ActiveRecord::Base.establish_connection :database=>db_name, :adapter=>'postgresql', :username=> db_user

begin
  ActiveRecord::Base.connection # tests DB connection
rescue ActiveRecord::NoDatabaseError => e
  puts
  puts "no database for tests: `#{db_name}`! Create one? (Y/n)"
  if $stdin.readline.chomp.gsub(/y/i,'') == ''
    `psql -c 'CREATE DATABASE #{db_name}'`
    retry
  else
    exit(1)
  end
end

ActiveRecord::Schema.define do
  drop_table :records if table_exists? :records

  create_table :records do |t|
  end
end

require_relative './model_fixture'
