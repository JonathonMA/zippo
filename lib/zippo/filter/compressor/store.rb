require 'zippo/filter/compressor'
require 'zippo/filter/null_filters'

module Zippo::Filter
  # StoreCompressor stores the original member data directly in the zip
  # file. No compression is performed.
  class StoreCompressor < Compressor
    METHOD = 0

    include NullFilters
  end
end
