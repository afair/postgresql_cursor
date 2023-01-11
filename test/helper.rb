$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'minitest'
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
  has_many :prices

  # create table records (id serial primary key);
  def self.generate(max=1_000)
    max.times do |i|
      connection.execute("insert into products values (#{i+1})")
    end
  end
end

class Price < ActiveRecord::Base
  belongs_to :product
end

Product.destroy_all
Product.generate(1000)
