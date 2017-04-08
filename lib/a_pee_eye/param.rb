# frozen_string_literal: true

module APeeEye
  # Handles string conversion for request params.
  # Will handle the conversion differently depending on if
  # it is an ID param e.g. controller/:id
  class Param
    attr_reader :name, :value

    def initialize(name, value, id: nil)
      @id = id == true ? true : false
      @name  = name
      @value = value
    end

    def id?
      @id
    end

    def to_s
      url_value = value.to_s.tr('#;\'""', '').gsub(' ', '%20')
      id? ? "/#{value}" : "#{name}=#{url_value}"
    end
  end
end
