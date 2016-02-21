$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'minitest'
require 'active_record'
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection(adapter: 'postgresql',
  database: ENV['TEST_DATABASE'] || 'postgresql_cursor_test',
  username: ENV['TEST_USER']     || ENV['USER'] || 'postgresql_cursor')

class Product < ActiveRecord::Base
  # create table records (id serial primary key);
  def self.generate(max=1_000)
    max.times do |i|
      connection.execute("insert into products values (#{i+1})")
    end
  end
end

Product.destroy_all
Product.generate(1000)
