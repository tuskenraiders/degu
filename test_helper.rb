require File.dirname(__FILE__) + '/../lib/has_set'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Base.silence do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :people do |t|
        t.string  :fullname
        t.integer :interests_bitfield, :default => 0
      end

      create_table :punks do |t|
        t.string :fullname
        t.string :bad_habits_bitfield
      end

      create_table :parties do |t|
        t.string  :location
        t.integer :drinks_set, :default => 0
        t.integer :music_bitfield, :default => 0
      end
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

enum :Interests do
  attr_reader :bitfield_index
  
  Art(0)
  Golf(1)
  Sleeping(2)
  Drinking(3)
  Dating(4)
  Shopping(5)
  
  def init(bitfield_index)
    @bitfield_index = bitfield_index
  end
end

enum :MusicStyles do
  attr_reader :bitfield_index
  
  Rock(0)
  Pop(1)
  RnB(2)
  
  def init(bitfield_index)
    @bitfield_index = bitfield_index
  end
end

enum :Drinks do
  attr_reader :bitfield_index
  
  Beer(0)
  Wine(1)
  CubaLibre(2)
  
  def init(bitfield_index)
    @bitfield_index = bitfield_index
  end
end

setup_db # Init the database for class creation

class Person < ActiveRecord::Base
  has_set :interests
end

class Punk < ActiveRecord::Base; end

class Party < ActiveRecord::Base
  has_set :drinks, :column_name => :drinks_set
end

teardown_db # And drop them right afterwards

