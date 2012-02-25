module Zippo
  module BinaryStructure
    class StructureMember
      def initialize(name, pack, options = {})
        @name = name
        @pack = pack
        @options = options
        @width = StructureMember.width(@pack)
      end
      # XXX unspec
      def dependent
        options[:size]
      end
      # XXX unspec
      attr_reader :width
      def self.width(pack)
        case pack
        when 'L' then 4
        when 'S' then 2
        when /^a(\d+)$/ then $1.to_i
        when 'a*' then nil
        end
      end
      attr_reader :name, :pack, :options

      def signature?
        options[:signature]
      end
    end
  end
end
