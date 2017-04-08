# frozen_string_literal: true

module LazyRecord
  # Macro for dynamic instance method generation. Best to use for one-liners.
  module Methods
    METHODS_MODULE_NAME = :DynamicMethods

    def lr_method(method_name, *method_args, method)
      include mod = get_or_set_mod(METHODS_MODULE_NAME)

      if method.respond_to?(:call)
        make_method_from_proc(mod, method_name, method)
      else
        make_method_from_string(mod, method_name, *method_args, method)
      end
    end

    def make_method_from_proc(mod, method_name, proc)
      mod.module_eval do
        send(:define_method, method_name, &proc)
      end
    end

    def make_method_from_string(mod, method_name, *method_args, method)
      method_args = method_args.map(&:to_s).join(', ')
      mod.module_eval do
        define_method(method_name) do |*params|
          block = eval("lambda { |#{method_args}| #{method} }")
          block.call(*params)
        end
      end
    end
  end
end
