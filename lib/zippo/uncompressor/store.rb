require 'zippo/uncompressor'

module Zippo
  class StoreUncompressor < Uncompressor
    METHOD = 0

    include NullFilters
  end
end
