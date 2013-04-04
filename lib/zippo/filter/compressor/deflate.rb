require 'zippo/filter/compressor'

module Zippo::Filter
  # Compresses the input data using zlib.
  class DeflateCompressor < Compressor
    METHOD = 8
    DEFAULT_COMPRESSION = Zlib::DEFAULT_COMPRESSION

    def initialize(io, compression_mode = DEFAULT_COMPRESSION)
      super(io)
      @zlib = Zlib::Deflate.new(compression_mode, -Zlib::MAX_WBITS)
    end

    private
    def filter(buf)
      @zlib.deflate(buf)
    end

    def tail_filter
      @zlib.finish unless @zlib.finished?
    end
  end
end
