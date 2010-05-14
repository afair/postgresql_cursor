require 'helper'

class TestPostgresqlCursor < Test::Unit::TestCase
  
  def test_load
    puts List.all.inspect
  end
  
  def test_cursor
    c = List.find_with_cursor(:all)
    puts c.inspect
  end
end
