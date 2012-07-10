require 'helper'

class TestPostgresqlCursor < Test::Unit::TestCase
  
  def test_each_row
    count = 0
    last_r = nil
    Model.where("id>0").each_row { |r| last_r = r; count += 1 }
    assert count >= 1000, "Not enough found"
    assert_equal Hash, last_r.class
  end

  def test_each_instance
    count = 0
    last_r = nil
    Model.where("id>0").each_instance { |r| last_r = r; count += 1 }
    assert count >= 1000, "Not enough found"
    assert_equal Model, last_r.class
  end

  def test_find_by_sql_with_cursor
    count = 0
    Model.find_by_sql_with_cursor("select * from records where id>0") do |r|
      puts r.inspect
      last_r = r
      count += 1
    end
    assert count >= 1000, "Not enough found: found #{count}"
    assert_equal Hash, last_r.class
  end

  #def test_cursor
  #  c = Model.find_with_cursor(:conditions=>["id>?",0], :cursor=>{:buffer_size=>10})
  #  mycount=0
  #  count = c.each { |r| mycount += 1 } 
  #  assert_equal mycount, count
  #end

  #def test_empty_set
  #  c = Model.find_with_cursor(:conditions=>["id<?",0])
  #  count = c.each { |r| puts r.class }
  #  assert_equal count, 0
  #end

  #def test_block
  #  Model.transaction do
  #    c = Model.find_with_cursor(:conditions=>["id<?",10]) { |r| r }
  #    r = c.next
  #    assert_equal r.class, Hash
  #  end
  #end

  #def test_sql
  #  c = Model.find_by_sql_with_cursor("select * from #{Model.table_name}")
  #  mycount=0
  #  count = c.each { |r| mycount += 1 } 
  #  assert_equal mycount, count
  #end

  #def test_loop
  # Model.transaction do 
  #   cursor = Model.find_with_cursor() { |record| record.symbolize_keys }
  #   while record = cursor.next do
  #     assert record[:id].class, Fixnum
  #     cursor.close if cursor.count >= 10 
  #   end
  #   assert_equal cursor.count, 10
  # end
  #end

end
