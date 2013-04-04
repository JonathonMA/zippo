require 'zippo/filter/uncompressor'

require 'zlib'
require 'stringio'

module Zippo::Filter
  # Uncompresses the data using Zlib.
  class DeflateUncompressor < Uncompressor
    METHOD = 8

    def initialize(io, compressed_size, zlib = Zlib::Inflate.new(-Zlib::MAX_WBITS)) # no header
      super(io, compressed_size)
      @zlib = zlib
    end

    private
    def filter(buf)
      @zlib.inflate(buf)
    end

    def tail_filter
      @zlib.finish
    end
  end
end
