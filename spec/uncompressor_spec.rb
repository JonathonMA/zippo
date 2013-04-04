require "spec_helper"

require "zippo/filter/uncompressor"
require "zippo/filter/uncompressors"

module Zippo::Filter
  describe Uncompressor do
    it "should be a factory for uncompressors" do
      Uncompressor.for(0).should eq StoreUncompressor
      Uncompressor.for(8).should eq DeflateUncompressor
      -> { Uncompressor.for(113) }.should raise_error(/unknown compression method/)
    end
  end
end
