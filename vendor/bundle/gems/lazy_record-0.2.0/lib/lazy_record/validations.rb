# frozen_string_literal: true

module LazyRecord
  # Validations callbacks. If validations don't pass then initialization
  # will return false.
  module Validations
    VALIDATIONS_MODULE_NAME = :ModelValidations

    def define_validation
      define_method(:validation) do |*params|
        params.each do |param|
          if send(param.to_sym).nil?
            puts "#{param} must be given", inspect
            return false
          end
        end
        self
      end
    end

    def lr_validates(*args)
      include mod = get_or_set_mod(VALIDATIONS_MODULE_NAME)
      mod.extend(Validations)
      opts = args.extract_options!
      @validations = args
      return unless opts[:presence] == true
      mod.module_eval do
        define_validation
      end
    end
  end
end
