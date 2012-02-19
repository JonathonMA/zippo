require 'zippo/zip_directory'
require 'zippo/zip_file_writer'

require 'forwardable'

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

    def initialize(filename, mode)
      @filename = filename
      @mode = mode
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

    extend Forwardable
    def_delegators :directory, :map, :[], :[]=, :each

    private
    def read?
      @mode.include? 'r'
    end

    def write?
      @mode.include? 'w'
    end

    def io
      @io ||= File.open(@filename, 'r:ASCII-8BIT')
    end
  end
end
