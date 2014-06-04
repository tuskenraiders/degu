require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

enum :Status, [ :NOT_STARTED, :IN_PROGRESS, :COMPLETE ]

enum :Fuzzy, [ :FooBar, :BarFoo ]

class RenumNameTest < ActiveRecord::Base
  renum :RenumTest, [ :Foo, :Bar ]
end

describe "basic enum" do

  it "creates a class for the value type" do
    Status.should be_an_instance_of(Class)
  end

  it "makes each value an instance of the value type" do
    Status::NOT_STARTED.should be_an_instance_of(Status)
  end

  it "exposes array of values" do
    Status.values.should == [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
    Status.all.should == [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
  end

  it "groks first and last to retreive value" do
    Status.first.should == Status::NOT_STARTED
    Status.last.should == Status::COMPLETE
  end

  it "enumerates over values" do
    Status.map {|s| s.name}.should == %w[NOT_STARTED IN_PROGRESS COMPLETE]
  end

  it "indexes values" do
    Status[2].should == Status::COMPLETE
    Color[0].should == Color::RED
    Status['2'].should == Status::COMPLETE
    Color['0'].should == Color::RED
  end

  it "provides index lookup on values" do
    Status::IN_PROGRESS.index.should == 1
    Color::GREEN.index.should == 1
  end

  it "provides an id on values" do
    Status::IN_PROGRESS.id.should == 1
    Color::GREEN.id.should == 1
  end


  it "provides name lookup on values" do
    Status.with_name('IN_PROGRESS').should == Status::IN_PROGRESS
    Color.with_name('GREEN').should == Color::GREEN
    Color.with_name('IN_PROGRESS').should be_nil
  end

  it "provides fuzzy name lookup on values" do
    Fuzzy[0].should == Fuzzy::FooBar
    Fuzzy[1].should == Fuzzy::BarFoo
    Fuzzy[:FooBar].should == Fuzzy::FooBar
    Fuzzy[:BarFoo].should == Fuzzy::BarFoo
    Fuzzy['FooBar'].should == Fuzzy::FooBar
    Fuzzy['BarFoo'].should == Fuzzy::BarFoo
    Fuzzy[:foo_bar].should == Fuzzy::FooBar
    Fuzzy[:bar_foo].should == Fuzzy::BarFoo
    Fuzzy['foo_bar'].should == Fuzzy::FooBar
    Fuzzy['bar_foo'].should == Fuzzy::BarFoo
    Fuzzy[Fuzzy::FooBar].should == Fuzzy::FooBar
    Fuzzy[Fuzzy::BarFoo].should == Fuzzy::BarFoo
  end

  it "provides a reasonable to_s for values" do
    Status::NOT_STARTED.to_s.should == "Status::NOT_STARTED"
  end

  it "makes values comparable" do
    Color::RED.should < Color::GREEN
  end
end

module MyNamespace
  enum :FooValue, %w( Bar Baz Bat )
end

describe "nested enum" do
  it "is namespaced in the containing module or class" do
    MyNamespace::FooValue::Bar.class.should == MyNamespace::FooValue
  end
end

enum :Color, [ :RED, :GREEN, :BLUE ] do
  def abbr
    name[0..0]
  end
end

describe "enum with a block" do
  it "can define additional instance methods" do
    Color::RED.abbr.should == "R"
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
    Size::Small.description.should == "Really really tiny"
  end

  it "works the same as the basic form with respect to ordering" do
    Size.values.should == [Size::Small, Size::Medium, Size::Large, Size::Unknown]
  end

  it "responds as expected to arbitrary method calls, in spite of using method_missing for value definition" do
    expect { Size.ExtraLarge() }.to raise_error(NoMethodError)
  end

  it "supports there being no extra data and no init() method defined, if you don't need them" do
    HairColor::BLONDE.name.should == "BLONDE"
  end

  it "calls the init method even if no arguments are provided" do
    Size::Unknown.description.should == "NO DESCRIPTION GIVEN"
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
    Rating::ThumbsDown.description.should == "real real bad"
    Rating::ThumbsUp.description.should == "so so good"
  end

  it "uses the implementation given at the top level if no alternate definition is given for an instance" do
    expect { Rating::NotRated.description }.to raise_error(NotImplementedError)
  end

  it "allows definition of a method on just one instance" do
    Rating::ThumbsUp.thumbs_up_only_method.should == "this method is only defined on ThumbsUp"
    expect { Rating::NotRated.thumbs_up_only_method }.to raise_error(NoMethodError)
  end
end

describe "<=> comparison issue that at one time was causing segfaults on MRI" do
  it "doesn't cause the ruby process to bomb!" do
    Color::RED.should < Color::GREEN
    Color::RED.should_not > Color::GREEN
    Color::RED.should < Color::BLUE
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
  it "should define methods with defaults for fields" do
    Foo1::Baz.foo.should == "my foo"
    Foo2::Baz.foo.should == "my foo"
    Foo1::Baz.bar.should == "my bar"
    Foo2::Baz.bar.should == "my bar"
    Foo1::Baz.baz.should == Foo1::Baz.__id__
    Foo2::Baz.baz.should == Foo2::Baz.__id__
  end
end

describe "serialize and deserialize via Marshal" do
  it "should define methods with defaults for fields" do
    Marshal.load(Marshal.dump(Status::NOT_STARTED)).should == Status::NOT_STARTED
  end
end

if defined?(::JSON)
  describe "serialize and deserialize via JSON" do
    it "should define methods with defaults for fields" do
      JSON(JSON(Status::NOT_STARTED)).should == Status::NOT_STARTED
    end

    it "should not serialize fields by default" do
      foo1_json = JSON(Foo1::Baz)
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      foo1_hash.keys.sort.should == %w[name json_class].sort
    end

    it "should serialize all fields if desired" do
      foo1_json = Foo1::Baz.to_json(:fields => true)
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      foo1_hash.keys.sort.should == %w[name json_class bar baz foo].sort
    end

    it "should serialize requested fields" do
      foo1_json = Foo1::Baz.to_json(:fields => [ :bar, 'baz' ])
      foo1_hash = JSON.parse(foo1_json, :create_additions => false)
      foo1_hash.keys.sort.should == %w[name json_class bar baz].sort
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
