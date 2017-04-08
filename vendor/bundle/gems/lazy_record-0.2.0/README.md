# LazyRecord
[![Code Climate](https://codeclimate.com/github/msimonborg/lazy_record/badges/gpa.svg)](https://codeclimate.com/github/msimonborg/lazy_record)

LazyRecord writes a bunch of boilerplate code for your POROs, similarly to what you'd expect ActiveRecord to do for your database-backed objects. This project is an attempt to understand and explore dynamic programming techniques in Ruby, and demystify some of the Rails magic. Maybe someone will find it useful.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lazy_record

## Usage

All objects that inherit from `LazyRecord::Base` get block syntax added to their `#initialize` method.

```ruby
class Thing < LazyRecord::Base
end

thing = Thing.new { |t| puts t.class.superclass }
# LazyRecord::Base
# => #<Thing id: 1>
```

Alternatively, if you want to inherit from another class, you can mix in the `LazyRecord::BaseModule` and get all the same results.

```ruby
class Thing
  include LazyRecord::BaseModule
end

thing = Thing.new { |t| puts t.class.superclass }
# Object
# => #<Thing id: 1>
```
Every LazyRecord object is assigned an auto-incrementing ID after initialization. IDs reset when the program is terminated.

Use `lr_attr_accessor` like you would use `attr_accessor`. You'll get hash syntax in your `#intialize` method for attribute setting.

```ruby
class Thing < LazyRecord::Base
  lr_attr_accessor :stuff, :junk
end

thing = Thing.new stuff: 'stuff' do |t|
  t.junk = 'junk'
end
# => #<Thing id: 1, stuff: "stuff", junk: "junk">
```

Validate presence of attributes with `lr_validates` like you would with ActiveRecord. Failed validations will return false and the ID will not be incremented. More validation options coming in the future.

```ruby
class Thing < LazyRecord::Base
  lr_attr_accessor :stuff, :junk
  lr_validates :stuff, presence: true
end

thing = Thing.new junk: 'junk'
ArgumentError
stuff must be given
#<Thing id: nil, stuff: nil, junk: "junk">
# => false
```
Use `lr_has_many` to set up associated collections of another class. `lr_belongs_to` will be added in a future update.

```ruby
class Whatever < LazyRecord::Base
end

class Thing < LazyRecord::Base
  lr_attr_accessor :stuff, :junk
  lr_validates :stuff, presence: true
  lr_has_many :whatevers
end

whatever = Whatever.new
# => #<Whatever id: 1>

thing = Thing.new do |t|
  t.stuff = 'stuff'
  t.whatevers << whatever
end
# => #<Thing id: 1, stuff: "stuff", junk: nil>

thing.whatevers
# => #<WhateverRelation [#<Whatever id: 1>]>
```

Use `lr_scope` and `#where` to create class scope methods and query objects. Works just like ActiveRecord scopes, including scope chaining. Only since it is all Ruby and no SQL, use `==` as the comparison operator.

```ruby
class Whatever < LazyRecord::Base
  lr_attr_accessor :party_value, :sleepy_value
  lr_scope :big_party, -> { where('party_value > 10') }
  lr_scope :low_sleepy, -> { where('sleepy_value < 10') }
end

class Thing < LazyRecord::Base
  lr_attr_accessor :stuff, :junk
  lr_validates :stuff, presence: true
  lr_has_many :whatevers
end

Whatever.new party_value: 12, sleepy_value: 12
Whatever.new party_value: 13, sleepy_value: 3
Whatever.new party_value: 4, sleepy_value: 11
Whatever.new party_value: 3, sleepy_value: 5
thing = Thing.new do |t|
  t.stuff = 'stuff'
  t.whatevers = Whatever.all
end
# => #<Thing id: 1, stuff: "stuff", junk: nil>

thing.whatevers.big_party
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>, #<Whatever id: 2, party_value: 13, sleepy_value: 3>]>

thing.whatevers.low_sleepy
# => #<WhateverRelation [#<Whatever id: 2, party_value: 13, sleepy_value: 3>, #<Whatever id: 4, party_value: 3, sleepy_value: 5>]>

thing.whatevers.big_party.low_sleepy
# => #<WhateverRelation [#<Whatever id: 2, party_value: 13, sleepy_value: 3>]>

Whatever.low_sleepy
# => #<WhateverRelation [#<Whatever id: 2, party_value: 13, sleepy_value: 3>, #<Whatever id: 4, party_value: 3, sleepy_value: 5>]>

Whatever.where('id == 1')
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>
```
You can also use hash syntax and block syntax with `.where`. Block syntax will yield each object in the collection to the block for evaluation.
```ruby
Whatever.where { |w| w.sleepy_value > 5 }
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>, #<Whatever id: 3, party_value: 4, sleepy_value: 11>]>
Whatever.where { |w| w.sleepy_value == w.party_value }
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>]>
```
When using hash syntax can be a value, an expression, or a Proc object.
```ruby
Whatever.where party_value: 12
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>]>
Whatever.where party_value: 7 + 6, sleepy_value: 3
# => #<WhateverRelation [#<Whatever id: 2, party_value: 13, sleepy_value: 3>]>
num = 6
Whatever.where party_value: -> { num * 2 }
# => #<WhateverRelation [#<Whatever id: 1, party_value: 12, sleepy_value: 12>]>
```
Use `lr_method` for an alternative API for defining short instance methods. Can use lambda syntax or string syntax. Best for quick one-liners. If the method references `self` of the instance, either explicitly or implicitly, it needs to use the string syntax, since anything passed into the lambda will be evaluated in the context of the Class level scope.

```ruby
class Whatever < LazyRecord::Base
  lr_attr_accessor :party_value, :sleepy_value, :right
  lr_scope :big_party, -> { where('party_value > 10') }
  lr_scope :low_sleepy, -> { where('sleepy_value < 10') }
end

class Thing < LazyRecord::Base
  lr_attr_accessor :stuff, :junk
  lr_validates :stuff, presence: true
  lr_has_many :whatevers
  lr_method :speak, -> (string) { puts string }
  lr_method :add_whatever, 'right', 'whatevers << Whatever.new(right: right)'
end

thing = Thing.new stuff: 'stuff'
thing.speak "I'm a thing"
# I'm a thing
# => nil

thing.add_whatever(true)
# => [#<Whatever id: 1, party_value: nil, sleepy_value: nil, right: true>]

thing.whatevers
# => #<WhateverRelation [#<Whatever id: 1, party_value: nil, sleepy_value: nil, right: true>]>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. There is an `example` directory with some LazyRecord classes defined.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/lazy_record.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
