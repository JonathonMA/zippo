require "spec_helper"

require "zippo/compressor/store"

module Zippo
  describe StoreCompressor do
    let (:data) { "a" * 20 }
    let (:io) { StringIO.new data }
    let (:out) { StringIO.new }
    it "should write the data" do
      compressor = StoreCompressor.new(io)
      size, csize, crc32 = compressor.compress_to out
      size.should eq 20
      csize.should eq 20
      crc32.should eq Zlib.crc32(data)
      out.string.should eq data
    end
  end
end
