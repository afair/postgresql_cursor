#!/usr/bin/env ruby
################################################################################
# To run this "app", do a "rake setup" first.
# To work with this app, run the "rake console" task, which loads this file.
################################################################################
require 'rubygems'
require 'bundler/setup'
require 'pg'
require 'active_record'
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['TEST_DATABASE'] || 'postgresql_cursor_test',
  host: ENV['TEST_DATABASE_HOST'],
  username: ENV['TEST_DATABASE_USER'] || ENV['USER'] || 'postgresql_cursor',
  password: ENV['TEST_DATABASE_PASSWORD']
)

ActiveRecord::Schema.define(version: 0) do
  create_table(:products, force: true) do |t|
    t.string :data
  end

  create_table(:prices, force: true) do |t|
    t.string :data
    t.integer :product_id
  end
end

class Product < ActiveRecord::Base
  def self.generate(max=1_000)
    Product.destroy_all
    max.times do |i|
      connection.execute("insert into products values (#{i})")
    end
  end

  def tests
    Product.where("id>0").each_row(block_size:100) { |r| p r["id"] } # Hash
    Product.where("id>0").each_instance(block_size:100) { |r| p r.id } # Instance
  end
end

#Product.generate
