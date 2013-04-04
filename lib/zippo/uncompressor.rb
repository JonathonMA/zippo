require 'zippo/filter'

module Zippo
  class Uncompressor
    include Filter

    def initialize(io, compressed_size)
      @io = io
      @compressed_size = compressed_size
      @remaining = @compressed_size
    end

    def read n, buf = nil
      if @remaining >= n
        @remaining -= n
      elsif (n = @remaining) > 0
        @remaining = 0
      else
        return nil
      end

      @io.read n, buf
      buf.replace filter(buf)
    end

    def uncompress_to io
      buf = ""
      while (read BLOCK_SIZE, buf)
        io << buf
      end
      io << tail_filter
    end

    def uncompress
      uncompress_to ""
    end
  end
end
