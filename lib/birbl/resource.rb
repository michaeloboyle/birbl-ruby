###
# Base class for a Birbl API resource.
#

require 'active_support/hash_with_indifferent_access'

module Birbl
  class Resource
    include ActiveModel::Naming
    include ActiveModel::Serialization
    include ActiveModel::Validations

    attr_accessor :attributes

    def self.attribute_names
      [:id]
    end

    def self.define_attributes
      attribute_names.each do |attribute|
        define_method attribute do
          attributes[attribute]
        end

        define_method "#{attribute}=" do |value|
          attributes[attribute] = value
        end
      end
    end

    def self.collection_path
      collection = '' + self.model_name.collection
      collection.gsub!(%r(^birbl/), '')
      collection
    end

    def self.client
      Birbl::Client.instance
    end

    def self.create(attributes = {}, parent = nil)
      resource = new(attributes, parent)
      resource.save
      resource
    end

    def self.all
      results = client.get(collection_path)
      results.map { |attributes| new(attributes) }
    end

    def self.find(id, attributes = {}, parent = nil)
      item = new(attributes.merge(:id => id), parent)
      attributes = client.get("#{ self.resource_name.pluralize }/#{ id }")
      new(attributes, parent)
    end

    def self.delete(id, attributes = {})
      item = new(attributes.merge(:id => id))
      client.delete(item.path)
    end

    def self.resource_name
      self.model_name.to_s.downcase.sub('birbl::', '')
    end

    def initialize(attributes = {}, parent = nil)
      self.attributes = HashWithIndifferentAccess.new
      attributes.each do |name, value|
        send "#{name}=", value
      end

      unless parent.nil?
        instance_variable_set("@#{ parent.class.resource_name }", parent)
      end
    end

    def address
      @address
    end

    def address=(data)
      @address = Birbl::Address.new(data)
    end

    def path
      self.class.collection_path + "/#{id}"
    end

    def post_path
      self.class.collection_path
    end

    def save
      was_new = new_record?
      result = was_new ? client.post(post_path, as_json) : client.put(path, as_json)
      self.id = result['id'] if was_new
      true
    end

    def delete
      client.delete(path)
    end

    def as_json
      attr = writable_attributes.symbolize_keys

      if defined?(@address)
        attr['address'] = @address.as_json
      end

      attr
    end

    def writable_attributes
      attributes
    end

    def new_record?
      id.nil?
    end

    # Get an array of this resource's child resources.
    #
    # They will be loaded from the API the first time they are requested
    def children(resource)
      existing = instance_variable_get("@#{ resource }")
      return existing unless existing.empty?

      data = Birbl::Client.instance.get("#{ path }/#{ resource }")
      data.each do |item|
        add_child(resource.singularize, item)
      end
      instance_variable_get("@#{ resource }")
    end

    # Add a child resource to this resource from the given data.
    #
    # If the child resource does not already have an id and autocreate is true,
    # it will automatically be sent to the API for creatiopn when this function is called
    def add_child(resource, data, autocreate = true)
      resource_model = "Birbl::#{ resource.camelize}".constantize
      parent_name = self.class.resource_name

      object =
        if autocreate && data['id'].nil?
          resource_model.create(data, self)
        else
          resource_model.new(data, self)
        end

      add_to_children(resource, object)
      attributes[resource.pluralize]<< data unless attributes[resource.pluralize].nil?

      object
    end

    # Get an child from this resource by it's id.
    #
    # The child resource will be loaded from the API the first time it is requested
    def child(resource, id)
      test = child_by_id(resource, id)
      return test unless test.nil?

      resource_model = "Birbl::#{ resource.camelize}".constantize

      object = resource_model.find(id, {}, self)
      add_to_children(resource, object)

      object
    end

    def child_by_id(resource, id)
      children(resource.pluralize).each { |o|
        return o if o.id == id
      }

      nil
    end

    private

    def add_to_children(resource, child)
      children = instance_variable_get("@#{ resource.pluralize }")
      children << child
      instance_variable_set("@#{ resource.pluralize }", children)
    end

    def client
      self.class.client
    end
  end
end
