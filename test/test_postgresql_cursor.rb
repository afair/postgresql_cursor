require 'helper'

class TestPostgresqlCursor < Test::Unit::TestCase
  
  def test_cursor
    c = Model.find_with_cursor(:conditions=>["id>?",0], :cursor=>{:buffer_size=>10})
    mycount=0
    count = c.each { |r| mycount += 1 } 
    assert_equal mycount, count
  end

  def test_empty_set
    c = Model.find_with_cursor(:conditions=>["id<?",0])
    count = c.each { |r| puts r.class }
    assert_equal count, 0
  end

  def test_block
    Model.transaction do
      c = Model.find_with_cursor(:conditions=>["id<?",10]) { |r| r }
      r = c.next
      assert_equal r.class, Hash
    end
  end

  def test_sql
    c = Model.find_by_sql_with_cursor("select * from #{Model.table_name}")
    mycount=0
    count = c.each { |r| mycount += 1 } 
    assert_equal mycount, count
  end

end
