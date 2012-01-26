require "zippo/version"
require 'zippo/zip_file'
require 'zippo/uncompressors'

module Zippo
  class << self
    def open filename, &block
      Zippo::ZipFile.open filename, &block
    end
    public :open
  end
end
