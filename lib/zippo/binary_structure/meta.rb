require 'zippo/binary_structure'

module Zippo::BinaryStructure
  module CodeGen
    class << self
      # Defines a method on the specified class that takes sets the specified instance variables
      def define_helper(klass, meth, fields)
        buf = []
        buf << "def #{meth}(#{0.upto(fields.size-1).map{|x|"a#{x}"}.join(',')})"
        fields.each_with_index do |field, i|
          buf << "@#{field} = a#{i}"
        end
        buf << "end"
        klass.class_eval buf.join("\n")
      end

      def fields_as_args(fields)
        fields.map {|f| "@#{f}"}.join(", ")
      end

      def call_helper(receiver, meth, fields)
        "#{receiver}.#{meth}(#{fields_as_args(fields)})"
      end

      def define_defaults_method_for(klass)
        buf = []
        buf << "def defaults"
        klass.structure.fields.each do |field|
          buf << %{@#{field.name} = #{field.options[:default].inspect}} if field.options[:default]
          buf << %{@#{field.name} = #{field.options[:signature].inspect}} if field.options[:signature]
        end
        buf << "self"
        buf << "end"
        klass.class_eval buf.join("\n")
      end

      # XXX - should write a spec for the "multiple helpers"
      # implementation, none of the current binary structures would make
      # use of it
      #def self.define_unpack_method
      def define_unpack_method_for(klass)
        buf = "def unpack\n"
        buf << "obj = self.class.structure.owner_class.new\n"
        helper_num = -1 # keep track of the number of helper methods we've created
        field_buf = []
        # iterate over the fields, gathering up the fixed fields in a
        # group. once a variable field is hit, unpack the current group of
        # fixed fields, then use that to read any variable fields. repeat.
        klass.structure.fields.each do |field|
          if field.options[:size]
            # unpack fixed group
            unless field_buf.empty?
              s = field_buf.map(&:width).inject(&:+)
              buf << %{arr = @io.read(#{s}).unpack("#{field_buf.map(&:pack).join('')}")\n}
              helper_name = "binary_structure_unpack_helper_#{helper_num += 1}"
              define_helper(klass.structure.owner_class, helper_name, field_buf.map(&:name))
              buf << "obj.#{helper_name}(*arr)\n"
            end
            # unpack variable-length field
            buf << %{obj.instance_variable_set :@#{field.name}, @io.read(obj.#{field.options[:size]})\n}
            field_buf = []
          else
            field_buf << field
          end
        end
        buf << "obj\n"
        buf << "end\n"

        klass.class_eval(buf)
      end

      def define_converter_for(klass, meth, other)
        # serialize the klass reference "other"
        # we can't just use to_s, since that won't work if the class is anonymous
        class_ref = "ObjectSpace._id2ref(#{other.object_id})"

        common_fields = klass.common_fields_with(other)

        helper_name = "initialize_from_#{object_id}"
        define_helper(other, helper_name, common_fields)

        klass.class_eval <<-_EOM_
          def #{meth}
            obj = #{class_ref}.new.defaults
            #{call_helper("obj", helper_name, common_fields)}
            obj
          end
        _EOM_
      end

      def define_pack_method_for klass
        buf = []

        fields = klass.structure.fields.map(&:name)
        packing_string = klass.structure.fields.map(&:pack).join('')

        helper_method =
          """
            def fields_for_packing
              [#{fields_as_args(fields)}]
            end
          """
        klass.structure.owner_class.class_eval helper_method

        klass.class_eval do
          define_method :pack do |obj|
            @io << obj.fields_for_packing.pack(packing_string)
          end
        end
      end
    end
  end

  after_structure_definition do |klass|
    # Pre-define the .defaults method
    CodeGen.define_defaults_method_for klass
    # Pre-define the .unpack method
    CodeGen.define_unpack_method_for klass::Unpacker
    # Pre-define the .unpack method
    CodeGen.define_pack_method_for klass::Packer
  end

  module InstanceMethods
    def convert_to other
      method = :"convert_to_#{other.object_id}"
      ::Zippo::BinaryStructure::CodeGen.define_converter_for(self.class, method, other) unless respond_to? method
      send method
    end
  end
end
