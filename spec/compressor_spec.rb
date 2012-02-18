require "spec_helper"

require "zippo/compressor"
require "zippo/compressors"

module Zippo
  describe Compressor do
    it "should be a factory for compressors" do
      Compressor.for(0).should eq StoreCompressor
#      Compressor.for(8).should eq DeflateCompressor
    end
  end
end
