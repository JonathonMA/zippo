require "spec_helper"

require "zippo/uncompressor"
require "zippo/uncompressors"
require "zippo/compressor"
require 'zippo/compressors'

module Zippo
  describe Uncompressor do
    let (:zstring) { Zlib::Deflate.new(Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS).deflate("a" * 20, Zlib::FINISH) }
    it "should allow uncompressors to work with compressors" do
      stream = StringIO.new zstring
      deflater = DeflateUncompressor.new(stream, zstring.size)
      storer = StoreCompressor.new(deflater)
      out = StringIO.new
      out.set_encoding "BINARY"
      storer.compress_to(out)
      out.string.should eq "a" * 20
    end
  end
end
