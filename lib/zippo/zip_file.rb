require 'zippo/zip_directory'

module Zippo
  class ZipFile
    def self.open(filename, mode = 'r')
      if block_given?
        zippo = new(filename, mode)
        a = yield zippo
        zippo.close
        return a
      else
        new filename, mode
      end
    end

    def read?
      @mode.include? 'r'
    end

    def write?
      @mode.include? 'w'
    end

    def initialize(filename, mode)
      @filename = filename
      @mode = mode
    end

    def [](member_name)
      directory[member_name]
    end
    def []= member_name, member_data
      directory[member_name] = member_data
    end
    def io
      @io ||= File.open(@filename, 'r:ASCII-8BIT')
    end
    def close
      @io.close if @io
      if write?
        writer = ZipFileWriter.new directory, @filename
        writer.write
      end
    end
    def directory
      @directory ||= if read?
        ZipDirectory.new io
      else
        ZipDirectory.new
      end
    end
  end
end
