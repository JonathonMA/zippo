require "spec_helper"

require "zippo/uncompressor/store"

module Zippo
  describe StoreUncompressor do
    let(:io) { StringIO.new "foobarbazquux" }
    let (:out) { StringIO.new }
    it "should read only the specified amount" do
      io.seek 3
      StoreUncompressor.new(io, 3).uncompress.should eq "bar"
    end
    it "should deflate to an IO" do
      io.seek 3
      StoreUncompressor.new(io, 3).uncompress_to(out)
      out.string.should eq "bar"
    end
  end
end
