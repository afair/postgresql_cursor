require 'helper'

class TestPostgresqlCursor < Test::Unit::TestCase
  
  def test_load
    #puts List.all.inspect
  end
  
  def test_cursor
    c = List.find_with_cursor(:conditions=>["list_id>?",0])
    #puts c.inspect
    c.each do |r| 
      puts r.inspect 
      puts r.class
    end
  end
end
