require 'helper'

class TestPostgresqlCursor < Test::Unit::TestCase

  def test_each
    c = PostgreSQLCursor.new("select * from records order by 1")
    nn = 0
    n = c.each { nn += 1}
    assert_equal nn, n
  end

  def test_enumerables
    assert_equal true, PostgreSQLCursor.new("select * from records order by 1").any?
    assert_equal false, PostgreSQLCursor.new("select * from records where id<0").any?
  end

  def test_each_while_until
    c = PostgreSQLCursor.new("select * from records order by 1", until:true)
    n = c.each { |r| r[:id].to_i > 100 }
    assert_equal 101, n

    c = PostgreSQLCursor.new("select * from records order by 1", while:true)
    n = c.each { |r| r[:id].to_i < 100 }
    assert_equal 100, n
  end

  def test_relation
    nn = 0
    Model.where("id>0").each_row {|r| nn += 1 }
    assert_equal 1000, nn
  end

  def test_activerecord
    nn = 0
    Model.each_row_by_sql("select * from records") {|r| nn += 1 }
    assert_equal 1000, nn

    nn = 0
    row = nil
    Model.each_instance_by_sql("select * from records") {|r| row = r; nn += 1 }
    assert_equal 1000, nn
    assert_equal Model, row.class
  end
  
end
