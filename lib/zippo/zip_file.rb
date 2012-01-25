require 'zippo/zip_directory'

module Zippo
  class ZipFile
    def self.open(filename)
      if block_given?
        zippo = new(filename)
        a = yield zippo
        zippo.close
        return a
      else
        new filename
      end
    end

    def initialize(filename)
      @filename = filename
    end

    def [](member_name)
      directory[member_name]
    end
    def io
      @io ||= File.open(@filename)
    end
    def close
      @io.close if @io
    end
    def directory
      ZipDirectory.new io
    end
  end
end
