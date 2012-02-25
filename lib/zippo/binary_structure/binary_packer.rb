module Zippo
  module BinaryStructure
    class BinaryPacker
      class << self
        attr_accessor :structure
      end

      def initialize(io)
        @io = io
      end

      def pack obj
        @io << self.class.structure.fields.map {|f| obj.send f.name}.pack(self.class.structure.fields.map(&:pack).join(""))
      end
    end
  end
end
