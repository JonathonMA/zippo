require 'zippo/filter/base'
require 'zlib'

module Zippo::Filter
  # A compressor is responsible for writing (and likely
  # compressing) data into a zip file.
  #
  # @example Obtaining a compressor
  #   compression_method = 8
  #   compressor = Compressor.for(compression_method).new(io)
  #   compressor.compress_to out
  #
  # Subclasse should include a METHOD constant to indicate
  # which zip compression method they handle. The actual
  # compression should be implemented in the filter and
  # tail_filter methods.
  class Compressor
    include Zippo::Filter::Base

    def initialize(io)
      @io = io
    end

    def read count = nil, buf = nil
      @io.read count, buf
    end

    def compress_to io
      data_size = 0
      compressed_size = 0
      crc32 = 0
      buf = ""
      while (read BLOCK_SIZE, buf)
        data_size += buf.bytesize
        compressed_size += io.write filter(buf)
        crc32 = Zlib.crc32(buf, crc32)
      end
      compressed_size += io.write tail_filter
      return compressed_size, data_size, crc32
    end
  end
end
