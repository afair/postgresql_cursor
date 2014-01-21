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

  def test_exception
    begin
      Model.each_row_by_sql("select * from records") do |r|
        raise "Oops"
      end
    rescue Exception => e
      assert_equal e.message, 'Oops'
    end
  end

  def test_pluck_each
    results = []
    Model.pluck_each(:id, children: [:id, :body]){ |row| results << row }
    if ::ActiveRecord::VERSION::MAJOR == 3
      assert_equal results[4,4], [["3", "5", "Lorem4"], ["3", "6", "Lorem5"], ["4", "7", "Lorem6"], ["4", "8", "Lorem7"]]
    else
      assert_equal results[4,4], [[3, 5, "Lorem4"], [3, 6, "Lorem5"], [4, 7, "Lorem6"], [4, 8, "Lorem7"]]
    end
  end

end
