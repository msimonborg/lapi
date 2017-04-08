# frozen_string_literal: true

module LazyRecord
  # Add special attr_accessors that automatically add initialization options
  # to your initialize method. Using lr_attr_accessor, you automatically get
  # an #initialize method that takes setter options for each attribute and
  # yields self to a block. If you want to add custom functionality to
  # #initialize just call super.
  module Attributes
    ATTR_MODULE_NAME = :DynamicAttributes

    def define_setters_and_getters(name)
      define_method(name) do
        instance_variable_get('@' + name.to_s)
      end

      define_method("#{name}=") do |val|
        instance_variable_set('@' + name.to_s, val)
      end
    end

    def define_instance_attrs_to_s
      define_method(:instance_attrs_to_s) do
        instance_attr_accessors.map do |attr|
          value = send(attr)
          "#{attr}: #{stringify_value(value)}"
        end
      end
      private :instance_attrs_to_s
    end

    def define_instance_attr_accessors(*names)
      define_method(:instance_attr_accessors) do
        names.map(&:to_sym)
      end
      private :instance_attr_accessors
    end

    def lr_attr_accessor(*names)
      include mod = get_or_set_mod(ATTR_MODULE_NAME)
      mod.extend(Attributes)
      mod.module_eval do
        names.each { |name| define_setters_and_getters(name) }
        define_instance_attr_accessors(*names)
        define_instance_attrs_to_s
      end
    end
  end
end
