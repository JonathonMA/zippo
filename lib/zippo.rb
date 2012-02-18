# Ensure binary structure optimisations are active before any structures are defined
require 'zippo/binary_structure/meta'

require "zippo/version"
require 'zippo/zip_file'
require 'zippo/uncompressors'

module Zippo
  class << self
    def open filename, mode = 'r', &block
      Zippo::ZipFile.open filename, mode, &block
    end
    public :open
  end
end
