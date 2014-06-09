#!/usr/bin/env ruby
################################################################################
# To run this "app", do a "rake setup" first
# To work with this app, load it from the root's "rake console" task,
# then do: require_relative 'test-app/app'
################################################################################
require 'rubygems'
require 'bundler/setup'
require 'pg'
require 'active_record'
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection( adapter: 'postgresql',
  database: ENV['TEST_DATABASE'] || 'postgresql_cursor_test',
  username: ENV['TEST_USER']     || ENV['USER'] || 'postgresql_cursor')

# create table products (id serial primary key);

class Product < ActiveRecord::Base
  def self.generate(max=1_000)
    max.times do |i|
      connection.execute("insert into products values (#{i})")
    end
  end
end

#Product.destroy_all
#Product.generate
#Product.where("id>0").each_row(block_size:100) { |r| p r["id"] } # Hash
#Product.where("id>0").each_instance(block_size:100) { |r| p r.id } # Instance
