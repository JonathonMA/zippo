require 'zippo/zip_directory'

module Zippo
  class ZipFile
    def self.open(filename)
      new filename
    end

    def initialize(filename)
      @filename = filename
    end

    def [](member_name)
      directory[member_name]
    end
    def close
    end
    def directory
      io = File.open(@filename)
      ZipDirectory.new io
    end
  end
end
