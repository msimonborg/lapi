# frozen_string_literal: true
# Example class
class Person < LazyRecord::Base
  lr_attr_accessor :name, :age, :haircut
  lr_has_many :dogs, :cats
  lr_accepts_nested_attributes_for :dogs, :cats

  lr_scope :new_with_dog, lambda { |opts = {}|
    opts[:dog] = {} unless opts[:dog]
    new(opts) { |p| p.adopt_a_dog(opts[:dog]) }
  }
  lr_scope :young, -> { where('age < 30') }
  lr_scope :old, -> { where { |x| x.age > 30 } }
  lr_scope :short_hair, -> { where(haircut: 'short') }

  lr_method :speak, ->(string) { puts string }
  lr_method :add_dog, :name, 'dogs << Dog.new(name: name)'
  lr_method :introduce_yourself, 'puts "Hello, my name is #{name}"'

  lr_validates :name, :age, presence: true

  def self.new(opts = {})
    puts 'hi'
    super
  end

  def self.make_people(*args)
    opts = args.extract_options!

    people = args.map do |arg|
      Person.new { |p| p.name = arg; p.age = 30 }
    end

    if opts[:count] == true
      puts "There are #{people.size} people!"
    end

    if opts[:dog]
      people.each do |person|
        person.adopt_a_dog(opts[:dog]) do |d|
          d.name = "#{person.name}'s best friend"
        end
      end
    end

    people.each { |person| yield person } if block_given?

    people
  end

  def times(num)
    if block_given?
      i = 0
      while i < num
        yield
        i += 1
      end
      i
    else
      self
    end
  end

  def adopt_a_dog(opts = {})
    dog = Dog.new(opts)
    yield dog if block_given?
    self.dogs << dog
    dog
  end

  JOE = new_with_dog(
    name: 'Joe',
    age: 35,
    haircut: 'short',
    dog: {
      cute: true,
      name: 'Frank',
      breed: 'Schnauzer',
      weight: 45,
      friend: true,
      years_known: 6
    }
  )
end
