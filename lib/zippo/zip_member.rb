require 'zippo/local_file_header_unpacker'
require 'zippo/uncompressor'

module Zippo
  class ZipMember
    def initialize io, header
      @io = io
      @header = header
    end
    def name
      @header.name
    end
    def read
      @io.seek @header.local_file_header_offset + local_file_header.size
      uncompressor.uncompress
    end
    def local_file_header
      @io.seek @header.local_file_header_offset
      LocalFileHeaderUnpacker.new(@io).unpack
    end
    def uncompressor
      Uncompressor.for(@header.compression_method).new(@io, @header.compressed_size)
    end
    def compressed_member_data
      @io.seek @header.local_file_header_offset
      @lfh ||= LocalFileHeaderUnpacker.new(@io).unpack
      @io.seek @header.local_file_header_offset + @lfh.size
      @io.read @header.compressed_size
    end
  end
end
