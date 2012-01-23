require 'zippo/central_directory_unpacker'

module Zippo
  class CentralDirectoryParser
    SIGNATURE = 0x06054b50
    PACKED_SIGNATURE = [SIGNATURE].pack('L')
    MAX_COMMENT_LENGTH = 1<<16
    def initialize(io)
      @io = io
    end
    def parse_entries
      @io.seek end_of_cd_record_position
      eocdr = CentralDirectoryUnpacker.new(@io.read).unpack
    end
    def end_of_cd_record_position
      # XXX implement optimised scanning at -22 position
      scan_size = [@io.size, MAX_COMMENT_LENGTH].min
      at = @io.size - scan_size
      @io.seek(at)
      @io.read(scan_size).rindex(PACKED_SIGNATURE).tap do |pos|
        raise "End of Central Directory Record not found" unless pos
      end
    end
  end
end
