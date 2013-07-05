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
