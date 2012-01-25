require 'zippo/uncompressor'

module Zippo
  class StoreUncompressor < Uncompressor
    METHOD = 0
    def uncompress
      read @compressed_size
    end
  end
end
