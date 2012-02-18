module Zippo
  class ZipFileWriter
    def initialize(directory, filename)
      @directory = directory
      @filename = filename
    end
    def write
      File.open(@filename,'wb:ASCII-8BIT') do |io|
        packer = LocalFileHeader::Packer.new io
        headers = []
        for member in @directory
          header = CdFileHeader.default
          header.compression_method = 8 # XXX configurable
          header.name = member.name
          header.extra_field = "" # XXX extra field unimplemented
          header_size = header.file_name_length + header.extra_field_length + 30

          # record header position so we can write it later
          header.local_file_header_offset = io.pos

          # move to after the header
          io.seek header_size, IO::SEEK_CUR

          # write the compressed data
          header.compressed_size,
            header.uncompressed_size,
            header.crc32 = member.write_to io, header.compression_method

          # write the completed header, returning to the current position
          io.seek header.local_file_header_offset
          #packer.pack LocalFileHeader.from header.convert_to LocalHileHeader
          packer.pack header.convert_to LocalFileHeader
          io.seek header.compressed_size, IO::SEEK_CUR
          headers << header
        end

        eocdr = EndCdRecord.default
        eocdr.cd_offset = io.pos
        packer = CdFileHeader::Packer.new io
        for header in headers
          packer.pack header
        end
        eocdr.cd_size = io.pos - eocdr.cd_offset
        eocdr.records = eocdr.total_records = headers.size
        EndCdRecord::Packer.new(io).pack eocdr
      end
    end
  end
end
