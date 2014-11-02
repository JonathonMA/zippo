module Zippo
  module BinaryStructure
    class Structure
      def self.create(owner_class, &block)
        structure = new(owner_class, &block)
        structure
      end
      def initialize(owner_class, &block)
        @fields = []
        @owner_class = owner_class
        instance_eval(&block)
      end

      def field(name, pack, options = {})
        @fields << StructureMember.new(name, pack, options)
      end

      def dependent?(field_name)
        fields.find do |field|
          field.options[:size] == field_name
        end
      end
      attr_reader :fields, :owner_class
    end
  end
end
