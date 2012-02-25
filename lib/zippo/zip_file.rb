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

    extend Forwardable
    def_delegators :directory, :map, :[], :[]=, :each

    def close
      # In update mode, we first write the zip to a temporary zip file,
      # then move it on top of the original file
      out_zip = update? ? tmp_zipfile : @filename
      ZipFileWriter.new(directory, out_zip).write if write?
      @io.close if @io
      File.rename out_zip, @filename if update?
    end

    def directory
      @directory ||= if read?
        ZipDirectory.new io
      else
        ZipDirectory.new
      end
    end

    private
    def read?
      File.exist? @filename and @mode.include? 'r'
    end

    def write?
      @mode.include? 'w'
    end

    def update?
      read? and write?
    end

    def io
      @io ||= File.open(@filename, 'r:ASCII-8BIT')
    end

    def tmp_zipfile
      # Not using Tempfile for performance
      # Should probably throw a timestamp in there, in case multiple
      # temps are being written at once from the one process
      File.join File.dirname(@filename), ".zippo-tmp-#{Process.pid}-#{File.basename(@filename)}"
    end
  end
end
