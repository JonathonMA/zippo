require 'zippo/uncompressor'

require 'zlib'

module Zippo
  class DeflateUncompressor < Uncompressor
    METHOD = 8
    def initialize(io, compressed_size, zlib = Zlib::Inflate.new(-Zlib::MAX_WBITS)) # no header
      super(io, compressed_size)
      @zlib = zlib
      @block_size = 1 << 13
    end
    def uncompress
      "".tap do |buf|
        n, rest = @compressed_size.divmod @block_size
        n.times { buf << @zlib.inflate(read @block_size) }
        buf << @zlib.inflate(read rest)
        buf << @zlib.finish
      end
    end
  end
end
