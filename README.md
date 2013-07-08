# Degu
![Build status](https://travis-ci.org/tuskenraiders/degu.png)

Degu bundles the renum Enumeration implementation with the has_enum and has_set
rails plugins.

## Renum

### Description

Renum provides a readable but terse enum facility for Ruby.  Enums are
sometimes called object constants and are analogous to the type-safe enum
pattern in Java, though obviously Ruby's flexibility means there's no such
thing as type-safety.

## Usage

Renum allows you to do things like this:
```ruby
enum :Status, %w( NOT_STARTED IN_PROGRESS COMPLETE )

enum :Size do
  Small("Really really tiny")
  Medium("Sort of in the middle")
  Large("Quite big")

  attr_reader :description

  def init description
    @description = description
  end
end

module MyNamespace
  enum :FooValue, [ :Bar, :Baz, :Bat ]
end
```
Giving you something that satisfies this spec, plus a bit more:
```ruby
  describe "enum" do

  it "creates a class for the value type" do
    Status.class.should == Class
  end

  it "makes each value an instance of the value type" do
    Status::NOT_STARTED.class.should == Status
  end

  it "exposes array of values" do
    Status.values.should == [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
  end

  it "provides an alternative means of declaring values where extra information can be provided for initialization" do
    Size::Small.description.should == "Really really tiny"
  end

  it "enumerates over values" do
    Status.map {|s| s.name}.should == %w[NOT_STARTED IN_PROGRESS COMPLETE]
  end

  it "indexes values" do
    Status[2].should == Status::COMPLETE
  end

  it "provides index lookup on values" do
    Status::IN_PROGRESS.index.should == 1
  end

  it "provides a reasonable to_s for values" do
    Status::NOT_STARTED.to_s.should == "Status::NOT_STARTED"
  end

  it "makes values comparable" do
    Status::NOT_STARTED.should < Status::COMPLETE
  end

  it "allows enums to be nested in other modules or classes" do
    MyNamespace::FooValue::Bar.class.should == MyNamespace::FooValue
  end

end
```
If your enumeration holds more than just a couple of attributes, the init method can become messy very quickly.
So, we have extended the original renum gem to ease the process of value definition.
```ruby
enum :Planet do
  field :mass
  field :radius
  field :satelites, default: 0
  field :human_name do |planet|
    planet.name.humanize
  end
  
  MERCURY(mass: 3.303e+23, radius: 2.4397e6)
  VENUS(mass: 4.869e+24, radius: 6.0518e6)
  EARTH(mass: 5.976e+24, radius: 6.37814e6, satelites: 1)
  MARS(mass: 6.421e+23, radius: 3.3972e6,  satelites: 2)
  JUPITER(mass: 1.9e+27,   radius: 7.1492e7,  satelites: 67)
  SATURN(mass: 5.688e+26, radius: 6.0268e7,  satelites: 62)
  URANUS(mass: 8.686e+25, radius: 2.5559e7,  satelites: 27)
  NEPTUNE(mass: 1.024e+26, radius: 2.4746e7,  satelites: 13)
  
  def has_satelites?
    satelites > 0
  end
end
```
Now, you are able to define your enumeration value attributes using the `field` method, which generates
`attribute_reader` for you. You can also specify a default value for this field using either the `:default`-key or
a block, if you need some calculation.
Now, you have a couple of methods to play with:
```ruby
# Enums implement Enumerable
Planet.map(&:human_name) 
 => ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

# access all enum value names
Planet.names
 => ["MERCURY", "VENUS", "EARTH", "MARS", "JUPITER", "SATURN", "URANUS", "NEPTUNE"]

# use the names as keys
Planet.underscored_names
 => ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
 
Planet.field_names
 => ["planet_mercury", "planet_venus", "planet_earth", "planet_mars", "planet_jupiter", "planet_saturn", "planet_uranus", "planet_neptune"]

Planet.values # returns all defined enum values as an array

# Use [] method to retrieve the values
Planet[2]
 => #<Planet:0x007ff2aa068bd8 @name="EARTH", @index=2, @mass=5.976e+24, @radius=6378140.0, @satelites=1, @human_name="Earth">

Planet['MARS']
 => #<Planet:0x007ff2aa0686d8 @name="MARS", @index=3, @mass=6.421e+23, @radius=3397200.0, @satelites=2, @human_name="Mars">
 
# Enums implement JSON load/dump API
serialized = Planet.to_json
 => "[{\"json_class\":\"Planet\",\"name\":\"MERCURY\"},{\"json_class\":\"Planet\",\"name\":\"VENUS\"},...]"

JSON.load(serialized) == Planet.values
 => true
```

### Renum License

This code is free to use under the terms of the MIT license.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
