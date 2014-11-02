# Ensure binary structure optimisations are active before any structures are defined
require 'zippo/binary_structure/meta'

require "zippo/version"
require 'zippo/zip_file'
require 'zippo/filter/uncompressors'

# Zippo is a Zip library.
module Zippo
  class << self
    # Calls Zippo::ZipFile.open
    # @see ZipFile.open
    def open(filename, mode = 'r', &block)
      Zippo::ZipFile.open filename, mode, &block
    end
    public :open
  end
end
