require 'zippo/uncompressor'

module Zippo
  class StoreUncompressor < Uncompressor
    METHOD = 0
    BLOCK_SIZE = 1 << 13

    def uncompress_to io
      n, rest = @compressed_size.divmod BLOCK_SIZE
      n.times { io << read(BLOCK_SIZE) }
      io << read(rest)
    end
  end
end
