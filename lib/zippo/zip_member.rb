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
      compressed_member_data
    end
    def compressed_member_data
      @io.seek @header.local_file_header_offset
      @lfh ||= LocalFileHeaderUnpacker.new(@io).unpack
      @io.seek @header.local_file_header_offset + @lfh.size
      @io.read @header.compressed_size
    end
  end
end
