# frozen_string_literal: true

require 'lazy_record/dynamic_modules'

module LazyRecord
  # After #initialize callbacks for validations and setting object id.
  module Callbacks
    def new(opts = {})
      @all ||= Relation.new(model: self)
      instance = super(opts)
      if instance.respond_to?(:validation)
        instance = instance.validation(*@validations)
      end
      add_id(instance)
    end

    def add_id(instance)
      if instance
        all << instance
        instance.send(:id=, count)
      end
      instance
    end

    private :add_id
  end
end
