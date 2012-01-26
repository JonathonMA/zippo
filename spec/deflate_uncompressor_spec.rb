require "spec_helper"

require "zippo/uncompressor/deflate"

module Zippo
  describe DeflateUncompressor do

    let (:zstring) { Zlib::Deflate.new(Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS).deflate("a" * 20, Zlib::FINISH) }
    let (:size) { zstring.size }
    let (:string) { "aaa" + zstring + "bbb" }
    let (:io) { StringIO.new string }
    it "should deflate only the compressed string" do
      io.seek 3
      DeflateUncompressor.new(io, size).uncompress.should eq "a" * 20
    end
  end
end
