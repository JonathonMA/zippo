require 'zippo/binary_structure/structure_member'
require 'zippo/binary_structure/structure'
require 'zippo/binary_structure/binary_packer'
require 'zippo/binary_structure/binary_unpacker'

module Zippo
  module BinaryStructure
    module Base
      def binary_structure &block
        @structure = Structure.create(self, &block)
        self.const_set :Packer, Class.new(BinaryPacker)
        self::Packer.structure = @structure
        self.const_set :Unpacker, Class.new(BinaryUnpacker)
        self::Unpacker.structure = @structure

        @structure.fields.each do |field|
          attr_reader field.name
          if @structure.dependent? field.name
            define_method "#{field.name}=" do |value|
              raise "can't mutate a dependent field"
            end
          else
            if field.dependent
              class_eval """
                def #{field.name}= value
                  @#{field.dependent} = value.bytesize
                  @#{field.name} = value
                end
              """
            else
              attr_writer field.name
            end
          end
        end
        include InstanceMethods
        extend ClassMethods
        Base.after_structure_definition_hooks_for(self)
      end
      class << self
        def after_structure_definition_hooks_for(klass)
          @hooks.each do |hook|
            hook.call(klass)
          end if @hooks
        end
        def after_structure_definition &block
          @hooks ||= []
          @hooks << block
        end
      end
      module InstanceMethods
        def defaults
          self.class.structure.fields.each do |field|
            instance_variable_set "@#{field.name}", field.options[:default] if field.options[:default]
            instance_variable_set "@#{field.name}", field.options[:signature] if field.options[:signature]
          end
          self
        end
        def size
          self.class.structure.fields.map do |field|
            if field.dependent
              send field.dependent
            else
              field.width
            end
          end.inject(&:+)
        end

        def convert_to other
          other.default.tap do |obj|
            self.class.common_fields_with(other).each do |field|
              obj.instance_variable_set "@#{field}", send(field)
            end
          end
        end
      end
      module ClassMethods
        attr_reader :structure
        def default
          new.defaults
        end

        # Returns the fields that this data type has in common with other
        # common fields are field with the same name
        # signature fields are never common
        def common_fields_with(other)
          structure.fields.map(&:name) &
            other.structure.fields.reject(&:signature?).map(&:name)
        end
      end
    end
  end
end
