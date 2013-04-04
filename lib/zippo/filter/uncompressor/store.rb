require 'zippo/filter/uncompressor'
require 'zippo/filter/null_filters'

module Zippo::Filter
  # StoreUncompressor returns the member data as stored in the zip file.
  # No uncompression is performed.
  class StoreUncompressor < Uncompressor
    METHOD = 0

    include NullFilters
  end
end
