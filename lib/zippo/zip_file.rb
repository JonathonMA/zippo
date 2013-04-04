require 'zippo/zip_directory'
require 'zippo/zip_file_writer'

require 'forwardable'

module Zippo
  # ZipFile represents a Zip archive.
  #
  # It can be called in block form like this:
  #
  #   Zippo.open("file.zip") do |zip|
  #     str = zip["file.txt"]
  #     other = zip["other/file.txt"]
  #     puts str
  #   end
  #
  # Or without a block:
  #
  #   zip = Zippo.open("file.zip")
  #   puts zip["file.txt"]
  #   zip.close
  #
  # == Inserting archive members
  #
  # New archive members can be inserted using the insert method:
  #
  #   zip = Zippo.open("out.zip", "w")
  #   zip.insert "out.txt", "something.txt"
  #
  # Additionally Zipfile#[]= has been overridden to support inserting
  # strings directly:
  #
  #   zip["other.txt"] = "now is the time"
  #
  # If you already have an IO object, you can just insert it:
  #
  #   io = File.open("foo.bin")
  #   zip.insert "rename.bin", io
  #
  # Finally, you can insert a Zippo::ZipMember from another Zip file,
  # which can allow the compressed data to be copied directly (avoiding
  # having to uncompress and then recompress it):
  #
  #   other = Zippo.open("other.zip")
  #   zip.insert "final.bin", other["final.bin"]
  #
  # No data will actually be written until the ZipFile is closed:
  #
  #   zip.close
  class ZipFile
    # Opens a zip archive file
    #
    # @param [String] filename path to the archive
    # @param [String] mode the mode to open in, 'r' or 'w' or 'rw'
    #
    # @return [Zippo::ZipFile] the opened zip file if no block is given
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

    # Closes the ZipFile, writing it to disk if it was opened in write
    # mode
    def close
      # XXX should optimize to not write anything to unchanged files
      # In update mode, we first write the zip to a temporary zip file,
      # then move it on top of the original file
      out_zip = update? ? tmp_zipfile : @filename
      ZipFileWriter.new(directory, out_zip).write if write?
      @io.close if @io
      File.rename out_zip, @filename if update?
    end

    # @return [ZipDirectory] the ZipDirectory
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
