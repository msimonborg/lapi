# frozen_string_literal: true

require 'lazy_record'

require 'lapi/param'
require 'lapi/parser'
require 'lapi/request'
require 'lapi/resource'
require 'lapi/response'
require 'lapi/response_object'
require 'lapi/version'

module LAPI
  module_function

  def new(name)
    api_name = name.to_s.camelize
    api = get_or_set_constant(api_name, Module.new)
    api.extend(API)
    self.apis << api
    yield api if block_given?
    create_scoped_constants(api)
  end

  def apis
    @apis ||= []
  end

  def create_scoped_constants(api)
    api.const_set('RESOURCES', api.resources)
    api.const_set('ALIASES', api.aliases)
    api.create_response_class
    api.create_parser_class
    api.create_request_class
    api
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

  module API
    include LAPI

    attr_reader :base_uri, :key

    def base_uri=(value)
      @base_uri = value
    end

    def key=(args = [])
      return if args.empty?
      @key = Param.new(args[0], args[1])
    end

    def resources
      @resources.dup.freeze
    end

    def aliases
      @aliases.dup.freeze
    end

    def add_resource(plural, singular = nil, &block)
      @resources ||= []
      @aliases ||= {}
      @resources << plural.to_sym
      add_inflection(plural, singular) if singular
      resource_builder = ResourceBuilder.new
      resource_builder.instance_eval(&block) if block
      resource_builder.aliases.each do |aka|
        @aliases[aka] = plural
      end
      response_object = get_or_set_constant plural.to_s.classify,
                                            Class,
                                            ResponseObject
      response_object.const_set('API_MODULE', self)
      response_object.class_eval do
        lr_attr_accessor(*resource_builder.attributes)
        lr_has_many(*resource_builder.collections)
        resource_builder.scopes.each do |k, v|
          lr_scope k, v
        end
      end
      resource_object = const_set(plural.to_s.camelize, Class.new(Resource))
      resource_object.class_eval do
        resource_builder.params.each do |param|
          define_method "#{param}=" do |value|
            instance_variable_set("@#{param}", Param.new(param.to_sym, value))
            self.class.send(:params) << instance_variable_get("@#{param}")
          end
        end
        self.class.send(:attr_reader, *resource_builder.params)
      end
      resource_object.params << @key if @key
      resource_builder.required.each do |name, value|
        resource_object.params << Param.new(name, value)
      end
    end

    def add_inflection(plural, singular)
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular singular, plural
      end
    end

    def create_response_class
      klass = const_set('Response', Class.new(Response))
      klass.const_set('BASE_URI', base_uri)
      klass.const_set('API_MODULE', self)
    end

    def create_parser_class
      klass = const_set('Parser', Class.new(Parser))
      klass.const_set('API_MODULE', self)
    end

    def create_request_class
      klass = const_set('Request', Class.new(Request))
      klass.const_set('API_MODULE', self)
    end

    def call(resource, id = nil)
      if resource.is_a?(LAPI::ResponseObject)
        request_object = { response_object: resource }
      elsif resource.to_s.include? base_uri
        request_object = { base_url: resource }
      else
        resource = self::Request.build(resource, id)
        yield resource if block_given?
        request_object = { base_url: base_uri, resource: resource }
      end
      self::Response.new request_object
    end

    class ResourceBuilder
      def params
        @params ||= []
      end

      def attributes
        @attributes ||= []
      end

      def collections
        @collections ||= []
      end

      def aliases
        @aliases ||= []
      end

      def scopes
        @scopes ||= {}
      end

      def required
        @required_params ||= {}
      end

      def optional_params(*args)
        @params = args
      end

      def add_attributes(*args)
        @attributes = args
      end

      def add_collections(*args)
        @collections = args
      end

      def add_aliases(*args)
        @aliases = args
      end

      def add_scopes(**args)
        @scopes = args
      end

      def required_params(**args)
        @required_params = args
      end
    end
  end
end
