require 'zippo/uncompressor'

require 'zlib'
require 'stringio'

module Zippo
  class DeflateUncompressor < Uncompressor
    METHOD = 8

    def initialize(io, compressed_size, zlib = Zlib::Inflate.new(-Zlib::MAX_WBITS)) # no header
      super(io, compressed_size)
      @zlib = zlib
    end

    def filter(buf)
      @zlib.inflate(buf)
    end

    def tail_filter
      @zlib.finish
    end
  end
end
