require 'zippo/cd_file_header'

require 'stringio'

module Zippo
  # Unpacks an array of CdFileHeaders from an io stream
  class CentralDirectoryEntriesUnpacker
    def initialize(io, size, offset)
      @io = io
      @size = size
      @offset = offset
      @end = @offset + @size
    end

    def unpack
      [].tap do |entries|
        @io.seek @offset
        while @io.pos < @end && entry = CdFileHeader::Unpacker.new(@io).unpack
          entries << entry
        end
      end
    end
 end
end
