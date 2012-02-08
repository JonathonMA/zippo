require "spec_helper"

require "zippo/zip_member"
require "zippo/uncompressor/store"
require "zippo/uncompressor/deflate"

module Zippo
  describe ZipMember do
    let(:io) { io_for "test.zip" }
    let(:cio) { io_for "deflate.zip" }
    let(:str) { "The quick brown fox jumps over the lazy dog.\n" }
    let(:header) { stub(:header, compression_method: 0, compressed_size: 45, local_file_header_offset: 0) }
    let(:cheader) { stub(:header, compression_method: 8, compressed_size: 37, local_file_header_offset: 0) }
    it "should work" do
      member = ZipMember.new io, header
      member.read.should eq str
    end
    it "should be able to write itself to an IO" do
      out = StringIO.new
      member = ZipMember.new io, header
      size, csize, crc32 = member.write_to out
      out.string.should eq str
      size.should eq str.size
      csize.should eq str.size
      crc32.should eq Zlib.crc32(str)
    end
    it "should work with compressed files" do
      member = ZipMember.new cio, cheader
      member.read.should eq "Methinks it is like a weasel.\n" * 10
    end
    describe ".with_name_and_data" do
      it "should initialse correctly" do
        member = ZipMember.with_name_and_data "name", "data"
        member.name.should eq "name"
      end
    end
  end
end
