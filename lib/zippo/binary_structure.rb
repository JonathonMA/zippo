# XXX unspec'd
module Zippo
  class BinaryStructureMember < Struct.new :name, :code, :options
    def variable?
      options[:size]
    end
    def variable_string?
      code == 'a*'
    end
    def width
      case code
      when 'L' then 4
      when 'S' then 2
      when /^a(\d+)$/ then $1
      end
    end
  end
  class BinaryStructure
    class << self
      attr_reader :fields
      def field name, code, options = {}
        @fields ||= {}
        @fields[name] = BinaryStructureMember.new(name, code, options)#[code, options]
        attr_reader name

        raise "size not found" if options[:size] && ! @fields[options[:size]]
      end

      def unpack_code
        "".tap do |buf|
          @fields.each do |name, field|
            buf << field.code
          end
        end
      end
      def field_groups
        [[]].tap do |groups|
          @fields.each do |name, field|
            if field.variable?
              groups << [field]
            else
              groups.last << field
            end
          end
        end
      end
      def unpack_codes
        field_groups.map do |group|
          group.map do |f|
            f.code
          end
        end
      end
      def sizes
        [[]].tap do |groups|
          @fields.each do |name, field|
            if field.variable?
            end
          end
        end
      end
      def unpack_from values, fields = @fields.keys, obj = new
        fields.zip(values).each do |field, value|
          obj.instance_variable_set "@#{field}", value
        end
      end
      def variable_size(obj)
        fields.values.select(&:variable?).map{|x| obj.send(x.options[:size])}.inject(&:+)
      end
      def fixed_size
        fields.values.reject(&:variable?).map(&:width).inject(&:+)
      end
    end
    def size
      self.class.fixed_size +
      self.class.variable_size(self)
    end
  end
  class BinaryUnpacker
    class << self
      attr_reader :klass
      def unpacks klass
        @klass = klass
      end
    end

    def initialize(input)
      if input.is_a? String
        @io = StringIO.new input
      else
        @io = input
      end
    end

    def klass
      self.class.klass
    end

    def unpack
      obj = klass.new
      fbuf = []
      # iterate over the fields, gathering up the fixed fields in a
      # group. once a variable field is hit, unpack the current group of
      # fixed fields, then use that to read any variable fields. repeat.
      klass.fields.values.each do |field|
        if field.variable?
          # unpack fixed group
          unless fbuf.empty?
            s = fbuf.map(&:width).inject(:+)
            arr = @io.read(s).unpack fbuf.map(&:code).join('')
            klass.unpack_from arr, fbuf.map(&:name), obj
          end
          # unpack variable
          obj.instance_variable_set "@#{field.name}", @io.read(obj.send(field.options[:size]))
          fbuf = []
        else
          fbuf << field
        end
      end
      return obj
    end
  end
end
