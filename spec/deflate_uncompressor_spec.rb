require "spec_helper"

require "zippo/filter/uncompressor/deflate"

module Zippo::Filter
  describe DeflateUncompressor do
    let(:zstring) { Zlib::Deflate.new(Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS).deflate("a" * 20, Zlib::FINISH) }
    let(:size) { zstring.size }
    let(:string) { "aaa" + zstring + "bbb" }
    let(:out) { StringIO.new }
    let(:io) { StringIO.new string }
    it "should deflate only the compressed string" do
      io.seek 3
      DeflateUncompressor.new(io, size).uncompress.should eq "a" * 20
    end
    it "should deflate to an IO" do
      io.seek 3
      DeflateUncompressor.new(io, size).uncompress_to(out)
      out.string.should eq "a" * 20
    end
  end
end
