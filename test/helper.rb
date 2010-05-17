require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection :database=>'allen_test', :adapter=>'postgresql', :username=>'allen'
class Model < ActiveRecord::Base
  set_table_name "records"

  # create table records (id serial primary key);
  def self.generate(max=1_000_000)
    max.times do
      connection.execute("insert into records values (nextval('records_id_seq'::regclass))")
    end
  end
end

Model.generate(1000) if Model.count == 0

class Test::Unit::TestCase
end
