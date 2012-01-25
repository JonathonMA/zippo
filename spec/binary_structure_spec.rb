require "spec_helper"

require 'zippo/binary_structure'

module Zippo
  describe BinaryStructure do
    context "when testing" do
      before(:each) do
        @klass = Class.new BinaryStructure
        @klass.class_eval do
          field :foo, 'L'
          field :bar, 'S'
          field :quux, 'a*', :size => :foo
        end
        @original_arr = [10,42,"foobar baz"]
        @other_arr = [3,42,"foobar baz"]
        @packed = @original_arr.pack 'LSa*'
        @other_packed = @other_arr.pack 'LSa*'
        @unpacker = Class.new BinaryUnpacker
        @unpacker.class_exec(@klass) do |k|
          unpacks k
        end
      end
      specify { @klass.unpack_codes.should eq [%w[L S], %w[a*]] }
      let(:unpacker) { @unpacker.new(packed) }
      let(:obj) { unpacker.unpack }
      let(:packed) { array.pack 'LSa*' }
      context "with a simple string" do
        let(:array) { [10,42,"foobar baz"] }
        specify { obj.foo.should eq 10 }
        specify { obj.bar.should eq 42 }
        specify { obj.quux.should eq 'foobar baz' }
      end
      context "with a nasty string" do
        let(:array) { [3,42,"foobar baz"] }
        specify { obj.quux.should eq 'foo' }
      end
      #it "should unpack things" do
      #  @unpacker.new(@packed).unpack.should eq @original_arr
      #end
      #it "should work with variable things" do
      #  @unpacker.new(@other_packed).unpack.should eq [3,42,"foo"]
      #end
    end
    it "should complain if the order is bad" do
      klass = Class.new BinaryStructure
      lambda { klass.class_eval do
        field :foo, 'S'
        field :bar, 'a*', :size => :baz
        field :baz, 'S'
      end }.should raise_error "size not found"
    end
    it "should remain silent if the order is ok" do
      klass = Class.new BinaryStructure
      lambda { klass.class_eval do
        field :foo, 'S'
        field :baz, 'S'
        field :bar, 'a*', :size => :baz
      end }.should_not raise_error
    end
  end
end
