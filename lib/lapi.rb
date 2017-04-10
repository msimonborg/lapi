# frozen_string_literal: true

require 'lazy_record'

require 'lapi/api'
require 'lapi/param'
require 'lapi/parser'
require 'lapi/request'
require 'lapi/resource'
require 'lapi/resource_builder'
require 'lapi/response'
require 'lapi/response_object'
require 'lapi/version'

module LAPI
  module_function

  def new(name)
    api_name = name.to_s.camelize
    api = get_or_set_constant(api_name, Module.new)
    api.extend(API)
    self.apis << api unless apis.include?(api)
    yield api if block_given?
    api.create_scoped_constants
    api
  end

  def apis
    @apis ||= []
  end

  def get_or_set_constant(const_name, klass, ancestor = nil)
    if const_defined?(const_name)
      const_get(const_name)
    elsif ancestor
      const_set(const_name, klass.new(ancestor))
    else
      const_set(const_name, klass)
    end
  end
end
