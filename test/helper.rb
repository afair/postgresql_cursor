require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'postgresql_cursor'

ActiveRecord::Base.establish_connection :database=>'allen', :adapter=>'postgresql', :username=>'allen'
class List < ActiveRecord::Base
  set_table_name "list"
end

class Test::Unit::TestCase
end
