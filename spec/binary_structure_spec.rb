require "spec_helper"

# TODO - spec that unpackers can take strings

require 'zippo/binary_structure'

module Zippo
  describe BinaryStructure do
    let(:klass) { Class.new }
    let(:obj) { klass.new }
    let(:unpacker) { klass.unpacker }
    before(:each) do
      klass.send :extend, BinaryStructure
    end
    context "when used to configure a class as a binary structure" do
      before(:each) do
        klass.class_eval do
          binary_structure do
            field :foo, 'L'
            field :bar, 'S'
            field :quux, 'a*', :size => :foo
          end
        end
      end
      it "should store field information in the class" do
        klass.structure.should have(3).fields
        klass.structure.fields[0].name.should eq :foo
        klass.structure.fields[2].options[:size].should eq :foo
      end
      it "should have dependent fields" do
        obj.quux = "foobar"
        obj.foo.should eq 6
        obj.quux.should eq "foobar"
      end
      it "should not allow mutation of dependent fields" do
        -> { obj.foo = 5 }.should raise_error
      end
      it "should have regular fields" do
        obj.bar = 10
        obj.bar.should eq 10
      end
      it "should have an unpacker" do
        array = [10,42,"foobar baz"]
        packed = array.pack 'LSa*'
        io = StringIO.new packed
        obj = klass.unpacker.new(io).unpack
        obj.foo.should eq 10
        obj.bar.should eq 42
        obj.quux.should eq "foobar baz"
      end
      it "should unpack oversized strings correctly" do
        array = [3,42,"foobar baz"]
        packed = array.pack 'LSa*'
        io = StringIO.new packed
        obj = klass.unpacker.new(io).unpack
        obj.quux.should eq "foo"
      end
      it "should have a packer" do
        array = [10,42,"foobar baz"]
        packed = array.pack 'LSa*'
        io = StringIO.new
        obj.bar = 42
        obj.quux = "foobar baz"
        klass.packer.new(io).pack obj
        io.string.should eq packed
      end
      it "should have a .size method" do
        obj.bar = 42
        obj.quux = "foobar baz"
        obj.size.should eq 16
      end
    end
=begin
    it "should complain if the order is bad" do
      pending
      klass = Class.new BinaryStructure
      lambda { klass.class_eval do
        field :foo, 'S'
        field :bar, 'a*', :size => :baz
        field :baz, 'S'
      end }.should raise_error "size not found"
    end
    it "should remain silent if the order is ok" do
      pending
      klass = Class.new BinaryStructure
      lambda { klass.class_eval do
        field :foo, 'S'
        field :baz, 'S'
        field :bar, 'a*', :size => :baz
      end }.should_not raise_error
    end
=end
  end
end
