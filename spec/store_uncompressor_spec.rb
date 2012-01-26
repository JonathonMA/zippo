require "spec_helper"

require "zippo/uncompressor/store"

module Zippo
  describe StoreUncompressor do
    let(:io) { StringIO.new "foobarbazquux" }
    it "should read only the specified amount" do
      io.seek 3
      StoreUncompressor.new(io, 3).uncompress.should eq "bar"
    end
  end
end
