# frozen_string_literal: true

require 'rails/generators'

module Lapi
  module Generators
    # Generate a configuration template for a basic API.
    class LapiGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :name,
               type: :string,
               required: true,
               banner: 'API Name'
      argument :uri,
               type: :string,
               required: false,
               banner: 'Base URI'
      argument :resources,
               type: :array,
               default: [],
               required: false,
               banner: 'resources'

      def copy_config_file
        template 'lapi.rb.erb', 'config/initializers/lapi.rb'
      end
    end
  end
end
