# Encoding: BINARY
require "spec_helper"

require "zippo/filter/compressor/deflate"

module Zippo::Filter
  describe DeflateCompressor do
    let (:data) { "a" * 20 }
    let (:zdata) { "KL\xC4\u0004\u0000" }
    let (:io) { StringIO.new data }
    let (:out) { StringIO.new "" }
    it "should write the data" do
      compressor = DeflateCompressor.new(io)
      csize, size, crc32 = compressor.compress_to out
      size.should eq 20
      csize.should eq zdata.size
      crc32.should eq Zlib.crc32(data)
      out.string.should eq zdata
    end
  end
end
