# frozen_string_literal: true
# Example class
class Cat < LazyRecord::Base
  lr_attr_accessor :name, :breed, :weight, :favorite_food
end
