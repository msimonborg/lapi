# frozen_string_literal: true

module LazyRecord
  # Set up in-memory associations between POROs.
  module Associations
    COLLECTION_MODULE_NAME   = :Collections
    NESTED_ATTRS_MODULE_NAME = :NestedAttributes

    def define_collection_getter(collection, class_name)
      model = apply_nesting(class_name).constantize
      define_method(collection) do
        if instance_variable_get("@#{collection}").nil?
          instance_variable_set("@#{collection}", Relation.new(model: model))
        end
        instance_variable_get("@#{collection}")
      end
    end

    def define_collection_setter(collection, class_name)
      model = apply_nesting(class_name).constantize
      define_method("#{collection}=") do |coll|
        coll = Relation.new(model: model, array: coll) if coll.is_a?(Array)
        return instance_variable_set("@#{collection}", coll) if coll.is_a? Relation
        raise ArgumentError, "Argument must be a collection of #{collection}"
      end
    end

    def define_collection_counter(collection)
      define_method("#{collection}_count") do
        send(collection).count
      end
    end

    def define_collections(*collections)
      define_method(:collections) do
        instance_variable_get(:@collections) || instance_variable_set(:@collections,
                                                                      collections)
      end
    end

    def define_collection_counts_to_s
      define_method(:collection_counts_to_s) do
        collections.map do |collection|
          "#{collection}_count: #{stringify_value(send("#{collection}_count"))}"
        end
      end
      private :collection_counts_to_s
    end

    def apply_nesting(class_name)
      "#{to_s.split('::')[0..-3].join('::')}::#{class_name}"
    end

    def lr_has_many(*collections)
      include mod = get_or_set_mod(COLLECTION_MODULE_NAME)
      mod.extend(Associations)
      mod.module_eval do
        define_collections(*collections)
        define_collection_counts_to_s
        collections.each do |collection|
          class_name = collection.to_s.classify
          define_collection_getter(collection, class_name)
          define_collection_setter(collection, class_name)
          define_collection_counter(collection)
        end
      end
    end

    def define_association_attributes_setter(collection, class_name)
      define_method("#{collection}_attributes=") do |collection_attributes|
        collection_attributes.values.each do |attributes|
          send(collection) << class_name.new(attributes)
        end
        collection
      end
    end

    def lr_accepts_nested_attributes_for(*collections)
      include mod = get_or_set_mod(NESTED_ATTRS_MODULE_NAME)
      mod.extend(Associations)
      mod.module_eval do
        collections.each do |collection|
          class_name = collection.to_s.classify.constantize
          define_association_attributes_setter(collection, class_name)
        end
      end
    end
  end
end
