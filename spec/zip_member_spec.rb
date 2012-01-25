require "spec_helper"

require "zippo/zip_member"

module Zippo
  describe ZipMember do
    let(:io) { io_for "test.zip" }
    let(:cio) { io_for "deflate.zip" }
    let(:header) { stub(:header, compression_method: 0, compressed_size: 45, local_file_header_offset: 0) }
    let(:cheader) { stub(:header, compression_method: 8, compressed_size: 37, local_file_header_offset: 0) }
    it "should work" do
      member = ZipMember.new io, header
      member.read.should eq "The quick brown fox jumps over the lazy dog.\n"
    end
    it "should work with compressed files" do
      member = ZipMember.new cio, cheader
      member.read.should eq "Methinks it is like a weasel.\n" * 10
    end
  end
end
