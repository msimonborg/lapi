# frozen_string_literal: true

module LAPI
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
            self.send(:params) << instance_variable_get("@#{param}")
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

    def create_scoped_constants
      const_set('RESOURCES', resources)
      const_set('ALIASES', aliases)
      create_response_class
      create_parser_class
      create_request_class
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
  end
end