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
    I18n.translate "enum.planet.#{planet.underscored_name}"
  end
  
  Mercury(mass: 3.303e+23, radius: 2.4397e6)
  Venus(mass: 4.869e+24, radius: 6.0518e6)
  Earth(mass: 5.976e+24, radius: 6.37814e6, satelites: 1)
  Mars(mass: 6.421e+23, radius: 3.3972e6,  satelites: 2)
  Jupiter(mass: 1.9e+27,   radius: 7.1492e7,  satelites: 67)
  Saturn(mass: 5.688e+26, radius: 6.0268e7,  satelites: 62)
  Uranus(mass: 8.686e+25, radius: 2.5559e7,  satelites: 27)
  Neptune(mass: 1.024e+26, radius: 2.4746e7,  satelites: 13)
  
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
 => ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

# use the names as keys
Planet.underscored_names
 => ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
 
Planet.field_names
 => ["planet_mercury", "planet_venus", "planet_earth", "planet_mars", "planet_jupiter", "planet_saturn", "planet_uranus", "planet_neptune"]

Planet.values # returns all defined enum values as an array

# Use [] method to retrieve the values
Planet[2]
 => #<Planet:0x007ff2aa068bd8 @name="Earth", @index=2, @mass=5.976e+24, @radius=6378140.0, @satelites=1, @human_name="Earth">

Planet['MARS']
 => #<Planet:0x007ff2aa0686d8 @name="Mars", @index=3, @mass=6.421e+23, @radius=3397200.0, @satelites=2, @human_name="Mars">

Planet[:venus]
 => #<Planet:0x007fe4227d9250 @name="Venus", @index=1, @mass=4.869e+24, @radius=6051800.0, @satelites=0, @human_name="Venus">

# Enums implement JSON load/dump API
serialized = Planet::Earth.to_json({})
 => "{\"json_class\":\"Planet\",\"name\":\"Earth\"}"

JSON.load serialized
 => #<Planet:0x007fe4227e1d38 @name="Earth", @index=2, @mass=5.976e+24, @radius=6378140.0, @satelites=1, @human_name="Earth">

# Because enums are static by their nature, it is sufficient to serialize just the name of the enum value.
# If you want to serialize the fields also, you can specify the field names to serialize (or just true for all fields)
Planet::Earth.to_json fields: [:name, :satelites]
 => "{\"json_class\":\"Planet\",\"name\":\"Earth\",\"satelites\":1}"
 
Planet::Earth.to_json fields: true
 => "{\"json_class\":\"Planet\",\"name\":\"Earth\",\"mass\":5.976e+24,\"radius\":6378140.0,\"satelites\":1,\"human_name\":\"Earth\"}" 
```

### Rails integration
To use enum values as ActiveRecord attributes we integrated the [has_enum](https://github.com/caroo/has_enum) and
[has_set](https://github.com/caroo/has_set) plugins, originally developed by [galaxycats](https://github.com/galaxycats).

#### has_enum
The has_enum extension provides an association with an enumeration class which requires the renum gem.
You have to make sure to have a column in your database table to store the string representation
of the associated enum instance. The plugin will look by default for a column named like the enum
itself plus the "_type" suffix.
```ruby

# Define the Enum-Class
enum :CustomerState do
  field :monthly_due
  
  Free(montly_due: 0)
  Basic(monthly_due: 5.95)
  Premium(monthly_due: 19.95)
  
end

# Class that has an Enumartion associated
class Customer < ActiveRecord::Base
  has_enum :customer_state # needs customer_state_type column in database
end

customer = Customer.new

# Before setting any enum
customer.customer_state # => nil
customer.customer_state_type # => ""

customer.customer_state = CustomerState::Premium
customer.customer_state # => CustomerState::Premium
customer.customer_state_type # => "Premium"
customer.customer_state_has_changed? # => true
```
`has_enum` method accepts following attributes:
- `column_name` to specify a different column name to store the enum values
- `class_name` to specify a different enum class

```ruby
class Customer
  has_enum :customer_state, class_name: 'UserState', column_name: 'state_type'
end
```

#### has_set
A simple plugin to enable any `ActiveRecord::Base` object to store a set of
attributes in a set like structure represented through a bitfield on the database level.

You only have to specify the name of the set to hold the attributes in question an the rest
is done for you through some fine selected Ruby magic. Here is a simple example of how you could use the plugin:
```ruby
class Person < ActiveRecord::Base
  has_set :interests
end
```

1. You need an unsigned 8(11)-Byte integer column in your database to store the bitfield.
  It is expected that the column is named after the name of the set with the suffix `_bitfield`
  appended (e.g. `interests_bitfield`). You can change that default behavior by providing the option `:column_name`
  (e.g. `has_set :interests, :column_name => 'my_custom_column'`).
2. You need a class that provides the valid values to be stored within the set and map the single bits back
   to something meaningful. The class should be named after the name of the set (you can change this through
   the `:enum_class` option). This class could be seen as an enumeration and must implement the following
   simple interface:
  * Each enumerator must implement a `name` method to return a literal representation for identification.
    The literal must be of the type `String`.
  * Each enumerator must implement a `bitfield_index` method to return the exponent of the number 2 for
    calculation the position of this enumerator in the bitfield. **Attention** Changing this index afterwards will
    destroy your data integrity.

The renum gem is best suited to satisfy this interface.
After that you get following methods to work with:

```ruby
enum :Interests do
  # bitfield_index is just the alias for the index method, but you are free to change it.
  # Just define a field :bitfield_index and set it for every enum value.
  Art()
  Golf()
  Sleeping()
  Drinking()
  Dating()
  Shopping()

end

person = Person.new

# Check the interests
person.interests
=> []

person.interests = [Interests::Art, Interests::Drinking]
=> [Interests::Art, Interests::Drinking]

person.interest_drinking?
=> true

person.interest_drinking = false
=> false

person.interest_drinking?
=> false

Person.available_interests
=> [:interest_art, :interest_golf, :interest_sleeping, :interest_drinking, :interest_dating, :interest_shopping]

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
