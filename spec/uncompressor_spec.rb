require "spec_helper"

require "zippo/uncompressor"
require "zippo/uncompressors"

module Zippo
  describe Uncompressor do
    it "should be a factory for uncompressors" do
      Uncompressor.for(0).should eq StoreUncompressor
      Uncompressor.for(8).should eq DeflateUncompressor
    end
  end
end
