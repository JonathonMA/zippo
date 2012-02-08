require "spec_helper"

require "zippo/io_zip_member"

module Zippo
  describe IOZipMember do
    let(:io) { StringIO.new "foobar" }
    let(:out) { StringIO.new }
    let(:name) { "name" }
    subject { IOZipMember.new name, io }
    specify { subject.name.should eq "name" }
    specify { subject.read.should eq "foobar" }
    context "when writing" do
      before(:each) do
        @size, @csize, @crc32 = subject.write_to out
      end
      it "should write to the io" do
        out.string.should eq "foobar"
      end
      it "should have returned the original size" do
        @size.should eq 6
      end
      it "should return the compressed size" do
        @csize.should eq 6
      end
      it "should return the CRC32" do
        @crc32.should eq Zlib.crc32("foobar")
      end
    end
  end
end
