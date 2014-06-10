require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

enum :Status, [ :NOT_STARTED, :IN_PROGRESS, :COMPLETE ]

enum :Fuzzy, [ :FooBar, :BarFoo ]

class RenumNameTest < ActiveRecord::Base
  renum :RenumTest, [ :Foo, :Bar ]
end

describe "basic enum" do

  it "creates a class for the value type" do
    expect(Status).to be_an_instance_of(Class)
  end

  it "makes each value an instance of the value type" do
    expect(Status::NOT_STARTED).to be_an_instance_of(Status)
  end

  it "exposes array of values" do
    expect(Status.values).to eq [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
    expect(Status.all).to eq [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
  end

  it "groks first and last to retreive value" do
    expect(Status.first).to eq Status::NOT_STARTED
    expect(Status.last).to eq Status::COMPLETE
  end

  it "enumerates over values" do
    expect(Status.map { |s| s.name }).to eq %w[NOT_STARTED IN_PROGRESS COMPLETE]
  end

  it "indexes values" do
    expect(Status[2]).to eq Status::COMPLETE
    expect(Color[0]).to eq Color::RED
    expect(Status['2']).to eq Status::COMPLETE
    expect(Color['0']).to eq Color::RED
  end

  it "provides index lookup on values" do
    expect(Status::IN_PROGRESS.index).to eq 1
    expect(Color::GREEN.index).to eq 1
  end

  it "provides an id on values" do
    expect(Status::IN_PROGRESS.id).to eq 1
    expect(Color::GREEN.id).to eq 1
  end


  it "provides name lookup on values" do
    expect(Status.with_name('IN_PROGRESS')).to eq Status::IN_PROGRESS
    expect(Color.with_name('GREEN')).to eq Color::GREEN
    expect(Color.with_name('IN_PROGRESS')).to be_nil
  end

  it "provides fuzzy name lookup on values" do
    expect(Fuzzy[0]).to eq Fuzzy::FooBar
    expect(Fuzzy[1]).to eq Fuzzy::BarFoo
    expect(Fuzzy[:FooBar]).to eq Fuzzy::FooBar
    expect(Fuzzy[:BarFoo]).to eq Fuzzy::BarFoo
    expect(Fuzzy['FooBar']).to eq Fuzzy::FooBar
    expect(Fuzzy['BarFoo']).to eq Fuzzy::BarFoo
    expect(Fuzzy[:foo_bar]).to eq Fuzzy::FooBar
    expect(Fuzzy[:bar_foo]).to eq Fuzzy::BarFoo
    expect(Fuzzy['foo_bar']).to eq Fuzzy::FooBar
    expect(Fuzzy['bar_foo']).to eq Fuzzy::BarFoo
    expect(Fuzzy[Fuzzy::FooBar]).to eq Fuzzy::FooBar
    expect(Fuzzy[Fuzzy::BarFoo]).to eq Fuzzy::BarFoo
  end

  it "provides a reasonable to_s for values" do
    expect(Status::NOT_STARTED.to_s).to eq "Status::NOT_STARTED"
  end

  it "makes values comparable" do
    expect(Color::RED).to be < Color::GREEN
  end
end

module MyNamespace
  enum :FooValue, %w( Bar Baz Bat )
end

describe "nested enum" do
  it "is namespaced in the containing module or class" do
    expect(MyNamespace::FooValue::Bar.class).to eq MyNamespace::FooValue
  end
end

enum :Color, [ :RED, :GREEN, :BLUE ] do
  def abbr
    name[0..0]
  end
end

describe "enum with a block" do
  it "can define additional instance methods" do
    expect(Color::RED.abbr).to eq "R"
  end
end

enum :Size do
  Small("Really really tiny")
  Medium("Sort of in the middle")
  Large("Quite big")
  Unknown()

  attr_reader :description

  def init description = nil
    @description = description || "NO DESCRIPTION GIVEN"
  end
end

enum :HairColor do
  BLONDE()
  BRUNETTE()
  RED()
end

describe "enum with no values array and values declared in the block" do
  it "provides another way to declare values where an init method can take extra params" do
    expect(Size::Small.description).to eq "Really really tiny"
  end

  it "works the same as the basic form with respect to ordering" do
    expect(Size.values).to eq [Size::Small, Size::Medium, Size::Large, Size::Unknown]
  end

  it "responds as expected to arbitrary method calls, in spite of using method_missing for value definition" do
    expect { Size.ExtraLarge() }.to raise_error(NoMethodError)
  end

  it "supports there being no extra data and no init() method defined, if you don't need them" do
    expect(HairColor::BLONDE.name).to eq "BLONDE"
  end

  it "calls the init method even if no arguments are provided" do
    expect(Size::Unknown.description).to eq "NO DESCRIPTION GIVEN"
  end
end

enum :Rating do
  NotRated()

  ThumbsDown do
    def description
      "real real bad"
    end
  end

  ThumbsUp do
    def description
      "so so good"
    end

    def thumbs_up_only_method
      "this method is only defined on ThumbsUp"
    end
  end

  def description
    raise NotImplementedError
  end
end

describe "an enum with instance-specific method definitions" do
  it "allows each instance to have its own behavior" do
    expect(Rating::ThumbsDown.description).to eq "real real bad"
    expect(Rating::ThumbsUp.description).to eq "so so good"
  end

  it "uses the implementation given at the top level if no alternate definition is given for an instance" do
    expect { Rating::NotRated.description }.to raise_error(NotImplementedError)
  end

  it "allows definition of a method on just one instance" do
    expect(Rating::ThumbsUp.thumbs_up_only_method).to eq "this method is only defined on ThumbsUp"
    expect { Rating::NotRated.thumbs_up_only_method }.to raise_error(NoMethodError)
  end
end

describe "<=> comparison issue that at one time was causing segfaults on MRI" do
  it "doesn't cause the ruby process to bomb!" do
    expect(Color::RED).to be < Color::GREEN
    expect(Color::RED).not_to be > Color::GREEN
    expect(Color::RED).to be < Color::BLUE
  end
end

modify_frozen_error =
  begin
    [].freeze << true
  rescue => e
    e.class
  end

describe "prevention of subtle and annoying bugs" do
  it "prevents you modifying the values array" do
    expect { Color.values << 'some crazy value' }.to raise_error(modify_frozen_error, /can't modify frozen/)
  end

  it "prevents you modifying the name hash" do
    expect { Color.values_by_name['MAGENTA'] = 'some crazy value' }.to raise_error(modify_frozen_error, /can't modify frozen/)
  end

  it "prevents you modifying the name of a value" do
    expect { Color::RED.name << 'dish-Brown' }.to raise_error(modify_frozen_error, /can't modify frozen/)
  end
end

enum :Foo1 do
  field :foo
  field :bar, :default => 'my bar'
  field :baz do |obj|
    obj.__id__
  end

  Baz(
    :foo => 'my foo'
  )
end

enum :Foo2 do
  field :foo
  field :bar, :default => 'my bar'
  field :baz do |obj|
    obj.__id__
  end


  Baz(
    :foo => 'my foo'
  )

  def init(opts = {})
    super
  end
end

describe "use field method to specify methods and defaults" do
  it "defines methods with defaults for fields" do
    expect(Foo1::Baz.foo).to eq "my foo"
    expect(Foo2::Baz.foo).to eq "my foo"
    expect(Foo1::Baz.bar).to eq "my bar"
    expect(Foo2::Baz.bar).to eq "my bar"
    expect(Foo1::Baz.baz).to eq Foo1::Baz.__id__
    expect(Foo2::Baz.baz).to eq Foo2::Baz.__id__
  end
end

describe "serialize and deserialize via Marshal" do
  it "defines methods with defaults for fields" do
    expect(Marshal.load(Marshal.dump(Status::NOT_STARTED))).to eq Status::NOT_STARTED
  end
end

if defined?(::JSON)
  describe "serialize and deserialize via JSON" do
    it "defines methods with defaults for fields" do
      expect(JSON(JSON(Status::NOT_STARTED))).to eq Status::NOT_STARTED
    end

    it "does not serialize fields by default" do
      foo1_json = JSON(Foo1::Baz)
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      expect(foo1_hash.keys.sort).to eq %w[name json_class].sort
    end

    it "serializes all fields if desired" do
      foo1_json = Foo1::Baz.to_json(:fields => true)
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      expect(foo1_hash.keys.sort).to eq %w[name json_class bar baz foo].sort
    end

    it "serializes requested fields" do
      foo1_json = Foo1::Baz.to_json(:fields => [ :bar, 'baz' ])
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      expect(foo1_hash.keys.sort).to eq %w[name json_class bar baz].sort
    end
  end
end

module ExtensionA
  def a
    'a_set_via_extension'
  end
end

module ExtensionB
  def b
    'b_set_via_extension'
  end
end

enum :Foo3 do
  definition_extension ExtensionA, ExtensionB do
    def c
      'c_set_via_extension'
    end
  end

  field :set_per_extension

  Bar(:set_per_extension => a)
  Baz(:set_per_extension => b)
  Bang(:set_per_extension => c)
end

describe "definition extensions included as models and block to use inside of the definition" do
  it "can use methods defined inside of definition extension modules" do
    expect(Foo3::Bar.set_per_extension).to eq 'a_set_via_extension'
    expect(Foo3::Baz.set_per_extension).to eq 'b_set_via_extension'
    expect(Foo3::Bang.set_per_extension).to eq 'c_set_via_extension'
  end
end
