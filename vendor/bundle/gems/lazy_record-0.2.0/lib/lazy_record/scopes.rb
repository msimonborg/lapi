# frozen_string_literal: true

module LazyRecord
  # Add ActiveRecord-style scope macros to your classes. Allows chaining.
  module Scopes
    SCOPE_MODULE_NAME = :ScopeMethods

    def lr_scope(method_name, lambda)
      extend mod = get_or_set_mod(SCOPE_MODULE_NAME)
      mod.module_eval do
        send(:define_method, method_name, &lambda)
      end
    end
  end
end
