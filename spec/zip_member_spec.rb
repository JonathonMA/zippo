require "spec_helper"

require "zippo/zip_member"
require "zippo/filter/uncompressor/store"
require "zippo/filter/uncompressor/deflate"

module Zippo
  describe ZipMember do
    let(:io) { io_for "test.zip" }
    let(:cio) { io_for "deflate.zip" }
    let(:str) { "The quick brown fox jumps over the lazy dog.\n" }
    let(:header) { double(:header, name: "foo", compression_method: 0, compressed_size: 45, uncompressed_size: 45, crc32: 3947940970, local_file_header_offset: 0) }
    let(:dheader) { double(:header, name: "foo/") }
    let(:cheader) { double(:header, compression_method: 8, compressed_size: 37, local_file_header_offset: 0) }
    it "should work" do
      member = ZipMember.new io, header
      member.read.should eq str
      member.should_not be_directory
    end
    it "should recognise a directory" do
      member = ZipMember.new io, dheader
      member.should be_directory
    end
    it "should be able to write itself to an IO" do
      out = StringIO.new ""
      member = ZipMember.new io, header
      size, csize, crc32 = member.write_to out, 0
      out.string.should eq str
      size.should eq str.size
      csize.should eq str.size
      crc32.should eq Zlib.crc32(str)
    end
    it "should work with compressed files" do
      member = ZipMember.new cio, cheader
      member.read.should eq "Methinks it is like a weasel.\n" * 10
    end
    pending "should be able to write to an IO using a streaming approach"
    pending "should be able to choose between recompressing or re-using the compressed data"
  end
end
