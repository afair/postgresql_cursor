require 'rubygems'
require 'bundler/setup'
require 'active_record'

class Model < ActiveRecord::Base
  #set_table_name "records"
  self.table_name = "records"

  # create table records (id serial primary key);
  def self.generate(max=1_000_000)
    max.times do
      connection.execute("insert into records values (nextval('records_id_seq'::regclass))")
    end
  end
end

Model.generate(1000) if Model.count == 0
