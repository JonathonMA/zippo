require 'stringio'

module Zippo
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
    # XXX - should write a spec for the "multiple helpers"
    # implementation, none of the current binary structures would make
    # use of it
    def self.define_unpack_method
      buf = "def unpack\n"
      buf << "obj = self.class.structure.owner_class.new\n"
      helpers = []
      field_buf = []
      # iterate over the fields, gathering up the fixed fields in a
      # group. once a variable field is hit, unpack the current group of
      # fixed fields, then use that to read any variable fields. repeat.
      @structure.fields.each do |field|
        if field.options[:size]
          # unpack fixed group
          unless field_buf.empty?
            s = field_buf.map(&:width).inject(&:+)
            buf << %{arr = @io.read(#{s}).unpack("#{field_buf.map(&:pack).join('')}")\n}
            helper_buf = ""
            helpers << helper_buf
            helper_buf << %{def binary_structure_unpack_helper_#{helpers.size-1}(#{0.upto(field_buf.size-1).map {|x| "a#{x}" }.join(", ")})\n}
            field_buf.each_with_index do |f, i|
              helper_buf << %{@#{f.name} = a#{i}\n}
            end
            helper_buf << %{end}
            buf << "obj.binary_structure_unpack_helper_#{helpers.size-1}(*arr)\n"
          end
          # unpack variable
          buf << %{obj.instance_variable_set :@#{field.name}, @io.read(obj.#{field.options[:size]})\n}
          field_buf = []
        else
          field_buf << field
        end
      end
      buf << "obj\n"
      buf << "end\n"

      self.class_eval(buf)
      helpers.each do |helper_buf|
        @structure.owner_class.class_eval(helper_buf)
      end
    end
  end
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
  module BinaryStructure
    def binary_structure &block
      @structure = Structure.create(self, &block)
      self.const_set :Packer, Class.new(BinaryPacker)
      self::Packer.structure = @structure
      self.const_set :Unpacker, Class.new(BinaryUnpacker)
      self::Unpacker.structure = @structure
      self::Unpacker.define_unpack_method

      @structure.fields.each do |field|
        attr_reader field.name
        if @structure.dependent? field.name
          define_method "#{field.name}=" do |value|
            raise "can't mutate a dependent field"
          end
        else
          if dependent_field = field.dependent
            define_method "#{field.name}=" do |value|
              instance_variable_set "@#{dependent_field}", value.size
              instance_variable_set "@#{field.name}", value
            end
          else
            define_method "#{field.name}=" do |value|
              instance_variable_set "@#{field.name}", value
            end
          end
        end
      end
      include InstanceMethods
      extend ClassMethods
    end
    module InstanceMethods
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
          (self.class.structure.fields.map(&:name) & other.structure.fields.map(&:name)).each do |field|
            if (fs = obj.class.structure.fields.detect {|f| f.name == field}).options[:signature]
              obj.instance_variable_set "@#{field}", fs.options[:signature]
            else
              obj.instance_variable_set "@#{field}", send(field)
            end
          end
        end
      end
    end
    module ClassMethods
      attr_reader :structure
      def default
        new.tap do |obj|
          structure.fields.each do |field|
            obj.instance_variable_set "@#{field.name}", field.options[:default] if field.options[:default]
          end
        end
      end
    end
  end
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
  end
  class Structure
    def self.create(owner_class, &block)
      structure = new(owner_class, &block)
      structure
    end
    def initialize(owner_class, &block)
      @fields = []
      @owner_class = owner_class
      instance_eval &block
    end
    def field name, pack, options = {}
      @fields << StructureMember.new(name, pack, options)
    end
    def dependent? field_name
      fields.detect do |field|
        field.options[:size] == field_name
      end
    end
    attr_reader :fields, :owner_class
  end
end

Class.class_eval do
  include Zippo::BinaryStructure
end
