require 'zippo/filter'

module Zippo
  class Uncompressor
    include Filter

    def initialize(io, compressed_size)
      @io = io
      @compressed_size = compressed_size
      @remaining = @compressed_size
    end

    def read n
      if @remaining >= n
        @remaining -= n
        @io.read n
      elsif (n = @remaining) > 0
        @remaining = 0
        @io.read n
      else
        return nil
      end
    end

    def uncompress_to io
      while (buf = read BLOCK_SIZE)
        io << filter(buf)
      end
      io << tail_filter
    end

    def uncompress
      uncompress_to ""
    end
  end
end
