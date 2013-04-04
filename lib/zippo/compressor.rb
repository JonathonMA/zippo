require 'zippo/filter'
require 'zlib'

module Zippo
  class Compressor
    include Filter

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
