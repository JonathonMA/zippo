require 'zippo/central_directory_unpacker'
require 'zippo/central_directory_entries_unpacker'

module Zippo
  class CentralDirectoryParser
    SIGNATURE = 0x06054b50
    PACKED_SIGNATURE = [SIGNATURE].pack('L')
    MAX_COMMENT_LENGTH = 1<<16
    # reads size from the specified offset
    # if offset is negative, will offset from EOF
    def read size, offset
      @io.seek offset, (offset < 0 ? IO::SEEK_END : IO::SEEK_SET)
      @io.read size
    end
    # reads from the specified offset until EOF
    def read_from offset
      read nil, offset
    end
    def initialize(io)
      @io = io
    end
    def end_of_cd_record
      CentralDirectoryUnpacker.new(read_from end_of_cd_record_position).unpack
    end
    def end_of_cd_record_position
      # XXX implement optimised scanning at -22 position
      scan_size = [@io.size, MAX_COMMENT_LENGTH].min
      read_from(-scan_size).rindex(PACKED_SIGNATURE).tap do |pos|
        raise "End of Central Directory Record not found" unless pos
      end
    end
    def cd_file_headers
      CentralDirectoryEntriesUnpacker.new(read end_of_cd_record.cd_size, end_of_cd_record.cd_offset).unpack
    end
  end
end
