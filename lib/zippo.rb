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
