# frozen_string_literal: true

require 'lazy_record'

module LAPI
  # The ResponseObject is the parent class of all objects instantiated
  # from the response body.
  class ResponseObject < LazyRecord::Base
    def initialize(opts = {})
      new_opts = opts.each_with_object({}) do |(key, val), memo|
        memo[key] = if resources.include?(key.to_sym)
                      objectify(key, val)
                    elsif resources.include?(key.to_s.pluralize.to_sym) && val.is_a?(Hash)
                      "#{api_module}::#{key.classify}".constantize.new(val)
                    elsif aliases.include?(key.to_sym)
                      "#{api_module}::#{aliases[key.to_sym].to_s.classify}".constantize.new(val)
                    else
                      val
                    end
      end
      super(new_opts)
    end

    def objectify(name, array)
      array.map { |obj| "#{api_module}::#{name.classify}".constantize.new(obj) }
    end

    def api_module
      self.class.const_get('API_MODULE')
    end

    def resources
      self.class.const_get("#{api_module}::RESOURCES")
    end

    def aliases
      self.class.const_get("#{api_module}::ALIASES")
    end

    def controller
      @controller ||= self.class.to_s.split('::').last.tableize
    end
  end
end
