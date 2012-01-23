# XXX unspec'd
module Zippo
  class BinaryStructure
    class << self
      def field name, code, options = {}
        @fields ||= {}
        @fields[name] = [code, options]
        attr_reader name
      end
      def unpack_code
        "".tap do |buf|
          @fields.each do |name, arr|
            code, options = *arr
            buf << code
          end
        end
      end
      def unpack_from values
        new.tap do |o|
          @fields.keys.zip(values).each do |field, value|
            o.instance_variable_set "@#{field}", value
          end
        end
      end
    end
  end
  class BinaryUnpacker
    class << self
      attr_reader :klass
      def unpacks klass
        @klass = klass
      end
    end

    def initialize(str)
      @str = str
    end

    def klass
      self.class.klass
    end

    def unpack
      klass.unpack_from @str.unpack klass.unpack_code
    end
  end
end
