# frozen_string_literal: true

module LazyRecord
  # Inherit from LazyRecord::Base to achieve lazier development.
  #
  # LazyRecord gives you some ActiveRecord-style conveniences for your in-memory
  # POROs. These include more powerful attr_accessors, object caching, instance
  # method generating macros, scope methods and scope chaining, associations
  # with other objects, and validations. This is a WIP still in development.
  class Base
    include BaseModule
  end
end
