require 'zippo/local_file_header_unpacker'
require 'zippo/uncompressor'

module Zippo
  class ZipMember
    def self.with_name_and_data name, data
      header = CdFileHeader.new
      header.name = name
      new(nil, header)
    end

    def initialize io, header
      @io = io
      @header = header
    end

    def name
      @name ||= @header.name
    end

    def read
      seek_to_compressed_data
      uncompressor.uncompress
    end

    # returns a duplicate of this zip member with the name overridden
    def with_name name
      dup.tap do |obj|
        obj.instance_variable_set :@name, name
      end
    end

    def write_to io
      size = io.write read
      return size, size, Zlib.crc32(read)
    end

    private
    def local_file_header
      @io.seek @header.local_file_header_offset
      LocalFileHeader.unpacker.new(@io).unpack
    end

    def seek_to_compressed_data
      @io.seek @header.local_file_header_offset + local_file_header.size
    end

    def uncompressor
      Uncompressor.for(@header.compression_method).new(@io, @header.compressed_size)
    end

    def compressed_member_data
      seek_to_compressed_data
      @io.read @header.compressed_size
    end
  end
end
