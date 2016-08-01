module NLU
  module Timeline
    def self.included(parent)
      #ap parent
    end

    def timeline
      @timeline ||= NLU::Timeline::IndividualObjectStore.new(self)
    end

    def set_attribute(attr_name, attr_value)
      timeline.update_attribute(attr_name, attr_value)
    end

    def attribute(name)
      GlobalStore.attribute_value_for_object(object: self, name: name.to_s)
    end

    # Store
    #
    # Holds a set of time objects
    class IndividualObjectStore
      def initialize(object)
        @object = object
        @attributes = []
      end

      def update_attribute(name, value)
        time_object = TimeObject.new(object: @object, name: name, value: value)
        @attributes << time_object
        GlobalStore.push(time_object)
      end

      def to_h
        @attributes
      end
    end

    # TimeObject
    #
    # Represents one event in time
    class TimeObject
      attr_accessor :name, :value, :object_id, :object_class

      def initialize(name:, value:, object:)
        @name = name.to_s
        @value = value
        @object_id = object.object_id
        @object_class = object.class.name
      end
    end

    class GlobalStore
      @@timeline = []

      def self.timeline
        @@timeline
      end

      def self.reset
        @@timeline = []
      end

      def self.push(object)
        @@timeline << object
      end

      def self.inspect
        @@timeline
      end

      def self.attribute_value_for_object(object:, name:)
        time_point = @@timeline.reverse.find do |time_point|
          time_point.object_id == object.object_id && time_point.name == name
        end

        time_point and time_point.value
      end
    end
  end
end
