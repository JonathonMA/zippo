require "spec_helper"

require "zippo/local_file_header"

module Zippo
  describe "LocalFileHeader::Unpacker" do
    before(:each) do
      @io = File.open test_file("test.zip"), "rb:ASCII-8BIT"
      @io.seek 0
    end
    after(:each) do
      @io.close
    end
    it "should unpack from an io" do
      LocalFileHeader::Unpacker.new(@io.read).unpack.name.should eq "test.file"
    end
  end
end
