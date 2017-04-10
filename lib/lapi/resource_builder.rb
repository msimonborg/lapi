# frozen_string_literal: true

module LAPI
  module API
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