require "spec_helper"

require "zippo/compressor"
require "zippo/compressors"

module Zippo
  describe Compressor do
    it "should be a factory for compressors" do
      Compressor.for(StoreCompressor::METHOD).should eq StoreCompressor
      Compressor.for(DeflateCompressor::METHOD).should eq DeflateCompressor
      -> { Compressor.for(113) }.should raise_error(/unknown compression method/)
    end
  end
end
