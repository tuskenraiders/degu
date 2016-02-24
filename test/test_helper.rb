require 'degu'
require 'test/unit'
require 'mocha/setup'
require 'active_record'
require 'degu/init_active_record_plugins'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :class_with_enums do |t|
      t.column :title, :string
      t.column :product_type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :class_without_enums do |t|
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :class_with_interger_columns do |t|
      t.column :title, :string
      t.column :product_type, :integer
    end

    create_table :class_with_custom_name_enums do |t|
      t.column :title, :string
      t.column :product_enum, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

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

    create_table :itunes do |t|
      t.string  :location
      t.integer :music_bitfield
    end

    create_table :class_with_large_datasets do |t|
      t.string :dataset_bitfield
    end

    create_table :two_enums_classes do |t|
      t.integer :drinks_bitfield, :default => 0
      t.string :dataset_bitfield, :default => '0'
    end
  end
end

def teardown_db
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Base.connection.data_sources.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  else
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end

enum :Fakes, [:NOT_DEFINIED]

enum :Product, [:Silver, :Gold, :Titanium]

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

enum :Dataset do
  65.times do |i|
    __send__("SetMember#{i}", {})
  end
end


setup_db # Init the database for class creation

class ClassWithEnum < ActiveRecord::Base
  has_enum :product
  attr_reader :callback1_executed
  def callback1
    @callback1_executed = true
  end

  after_save :callback1
end

class ClassWithoutEnum < ActiveRecord::Base; end

class ClassWithCustomNameEnum < ActiveRecord::Base
  has_enum :product, :column_name => :product_enum
end

class Person < ActiveRecord::Base
  has_set :interests
end

class Punk < ActiveRecord::Base; end

class Party < ActiveRecord::Base
  has_set :drinks, :column_name => :drinks_set
end

class Itunes < ActiveRecord::Base
  has_set :music, :enum_class => MusicStyles
end

class ClassWithIntergerColumn < ActiveRecord::Base
  has_enum :product
end

class ClassWithLargeDataset < ActiveRecord::Base
  has_set :dataset
end

class TwoEnumsClass < ActiveRecord::Base
  has_set :drinks
  has_set :dataset
end

teardown_db # And drop them right afterwards
