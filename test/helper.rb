require 'rubygems'
require 'test/unit'
require 'active_record'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection :database=>'allen_test', :adapter=>'postgresql', :username=>'allen'
class Model < ActiveRecord::Base
  #set_table_name "records"
  self.table_name = "records"

  has_many :children, class_name: "ChildModel", inverse_of: :parent, foreign_key: "parent_id"

  # create table records (id serial primary key);
  def self.generate(max=1_000_000)
    max.times do |i|
      connection.execute("insert into records values (#{i+1})")
    end
  end
end

class ChildModel < ActiveRecord::Base
  self.table_name = "child_records"
  belongs_to :parent, class_name: "Model", inverse_of: :children

  def self.generate(max=1_000_000)
    max.times do |i|
      connection.execute("insert into child_records values (#{i+1}, 'Lorem#{i}', #{i/2 + 1})")
    end
  end
end

Model.delete_all
Model.generate(1000)

ChildModel.delete_all
ChildModel.generate(1000)

class Test::Unit::TestCase
end
