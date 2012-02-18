require 'zippo/compressor'

module Zippo
  class DeflateCompressor < Compressor
    METHOD = 8
    DEFAULT_COMPRESSION = Zlib::BEST_COMPRESSION

    def initialize(io, compression_mode = DEFAULT_COMPRESSION)
      super(io)
      @zlib = Zlib::Deflate.new(compression_mode, -Zlib::MAX_WBITS)
    end

    def filter(buf)
      @zlib.deflate(buf)
    end

    def tail_filter
      @zlib.finish
    end
  end
end
