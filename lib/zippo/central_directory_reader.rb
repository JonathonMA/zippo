require 'zippo/end_cd_record'
require 'zippo/central_directory_entries_unpacker'

module Zippo
  # Reads the zip central directory from an IO stream.
  class CentralDirectoryReader
    def initialize(io)
      @io = io
    end

    def end_of_cd_record
      @end_of_cd_record ||= EndCdRecord::Unpacker.new(read_from end_of_cd_record_position).unpack
    end

    def cd_file_headers
      @cd_file_headers ||= CentralDirectoryEntriesUnpacker.new(@io, end_of_cd_record.cd_size, end_of_cd_record.cd_offset).unpack
    end

    def end_of_cd_record_position
      # XXX implement optimised scanning at -22 position
      [44, 22].each do |pos|
        next if pos > @io.size
        return @io.size - pos if (read 4, -pos) == EndCdRecord::PACKED_SIGNATURE
      end

      scan_from = @io.size - EndCdRecord::MAX_COMMENT_LENGTH
      scan_from = 0 if scan_from < 0
      scan_from + (read_from(scan_from).rindex(EndCdRecord::PACKED_SIGNATURE) or fail "End of Central Directory Record not found")
    end

    private
    # reads size from the specified offset
    # if offset is negative, will offset from EOF
    def read(size, offset)
      @io.seek offset, (offset < 0 ? IO::SEEK_END : IO::SEEK_SET)
      @io.read size
    end

    # reads from the specified offset until EOF
    def read_from(offset)
      read nil, offset
    end
  end
end
