require 'stringio'

module Zippo
  module BinaryStructure
    class BinaryUnpacker
      class << self
        attr_accessor :structure
      end

      def initialize(io)
        @io = io
        @io = StringIO.new @io if @io.is_a? String
      end

      # default implementation
      # note that this will generally be overridden by
      # define_unpack_method for optimisation
      def unpack
        self.class.structure.owner_class.new.tap do |obj|
          self.class.structure.fields.each do |field|
            if field.options[:size]
              obj.instance_variable_set "@#{field.name}", @io.read(obj.send field.options[:size])
            else
              buf = @io.read field.width
              obj.instance_variable_set "@#{field.name}", buf.unpack(field.pack).first
            end
          end
        end
      end
    end
  end
end
