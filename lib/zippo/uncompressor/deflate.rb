require 'zippo/uncompressor'

require 'zlib'
require 'stringio'

module Zippo
  class DeflateUncompressor < Uncompressor
    METHOD = 8

    def initialize(io, compressed_size, zlib = Zlib::Inflate.new(-Zlib::MAX_WBITS)) # no header
      super(io, compressed_size)
      @zlib = zlib
      @block_size = 1 << 13
    end

    def uncompress
      StringIO.new.tap{|x| uncompress_to(x) }.string
    end

    def uncompress_to io
      n, rest = @compressed_size.divmod @block_size
      n.times { io << @zlib.inflate(read @block_size) }
      io << @zlib.inflate(read rest)
      io << @zlib.finish
    end
  end
end
