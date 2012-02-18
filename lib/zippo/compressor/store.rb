require 'zippo/compressor'

module Zippo
  class StoreCompressor < Compressor
    METHOD = 0

    include NullFilters
  end
end
