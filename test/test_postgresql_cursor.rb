################################################################################
# Before running test, set up the test db & table with:
#     rake setup
# or create the database manually if your environment doesn't permit
################################################################################
require_relative 'helper'
require 'minitest/autorun'
require 'minitest/pride'

class TestPostgresqlCursor < Minitest::Test

  def test_each
    c = PostgreSQLCursor::Cursor.new("select * from products order by 1")
    nn = 0
    n = c.each { nn += 1}
    assert_equal nn, n
  end

  def test_enumerables
    assert_equal true, PostgreSQLCursor::Cursor.new("select * from products order by 1").any?
    assert_equal false, PostgreSQLCursor::Cursor.new("select * from products where id<0").any?
  end

  def test_each_while_until
    c = PostgreSQLCursor::Cursor.new("select * from products order by 1", until:true)
    n = c.each { |r| r[:id].to_i > 100 }
    assert_equal 1000, n

    c = PostgreSQLCursor::Cursor.new("select * from products order by 1", while:true)
    n = c.each { |r| r[:id].to_i < 100 }
    assert_equal 1000, n
  end

  def test_relation
    nn = 0
    Product.where("id>0").each_row {|r| nn += 1 }
    assert_equal 1000, nn
  end

  def test_activerecord
    nn = 0
    row = nil
    Product.each_row_by_sql("select * from products") {|r| row = r; nn += 1 }
    assert_equal 1000, nn
    assert_equal Hash, row.class

    nn = 0
    Product.each_instance_by_sql("select * from products") {|r| row = r; nn += 1 }
    assert_equal 1000, nn
    assert_equal Product, row.class
  end

  def test_exception
    begin
      Product.each_row_by_sql("select * from products") do |r|
        raise "Oops"
      end
    rescue Exception => e
      assert_equal e.message, 'Oops'
    end
  end

  def test_exception_raised_by_active_record
    begin
      Product.each_row_by_sql("SELECT * FROM unknown_table") {}
    rescue => e
      assert e.message.match('PG::UndefinedTable')
    end
  end

  def test_cursor
    cursor = Product.all.each_row
    assert cursor.respond_to?(:each)
    r = cursor.map { |row| row["id"] }
    assert_equal 1000, r.size
    cursor = Product.each_row_by_sql("select * from products")
    assert cursor.respond_to?(:each)
    r = cursor.map { |row| row["id"] }
    assert_equal 1000, r.size
  end

  def test_pluck
    r = Product.pluck_rows(:id)
    assert_equal 1000, r.size
    r = Product.all.pluck_instances(:id)
    assert_equal 1000, r.size
    assert_equal Fixnum, r.first.class
  end

end
