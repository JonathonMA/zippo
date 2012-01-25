require 'zippo/binary_structure'

module Zippo
  class CdFileHeader < BinaryStructure
    SIGNATURE = 0x02014b50
    field :signature, 'L', :default => SIGNATURE, :no_copy => true
    field :version_made_by, 'S', :default => 0
    field :version_extractable_by, 'S', :default => 20
    field :bit_flags, 'S', :default => 0
    field :compression_method, 'S'
    field :last_modified_time, 'S', :default => 0
    field :last_modified_date, 'S', :default => 0
    field :crc32, 'L'
    field :compressed_size, 'L'
    field :uncompressed_size, 'L'
    field :file_name_length, 'S'
    field :extra_field_length, 'S', :default => 0
    field :file_comment_length, 'S', :default => 0
    field :disk_number, 'S', :default => 0
    field :internal_file_attributes, 'S', :default => 0
    field :external_file_attributes, 'L', :default => 0
    field :local_file_header_offset, 'L'
    field :name, 'a*', :size => :file_name_length
    field :extra_field, 'a*', :size => :extra_field_length, :default => ''
    field :comment, 'a*', :default => '', :size => :file_comment_length, :default => ''
  end
  class CdFileHeaderUnpacker < BinaryUnpacker
    unpacks CdFileHeader
  end
  class CentralDirectoryEntriesUnpacker
    def initialize(str)
      @str = str
    end
    def unpack
      [].tap do |entries|
        io = StringIO.new @str
        while ! io.eof? && entry = CdFileHeaderUnpacker.new(io).unpack
          entries << entry
        end
      end
    end
 end
end
