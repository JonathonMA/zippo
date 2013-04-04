require 'zippo/binary_structure'

module Zippo
  # A Zip central directory file header.
  class CdFileHeader
    # The central file header signature from APPNOTE.TXT
    SIGNATURE = 0x02014b50
    binary_structure do
      # @!macro [attach] bs.field
      #   @!attribute [rw] $1
      field :signature, 'L', :signature => SIGNATURE
      field :version_made_by, 'S', :default => 0
      field :version_extractable_by, 'S', :default => 20
      field :bit_flags, 'S', :default => 0
      field :compression_method, 'S'
      field :last_modified_time, 'S', :default => 0
      field :last_modified_date, 'S', :default => 0
      field :crc32, 'L'
      field :compressed_size, 'L'
      field :uncompressed_size, 'L'
      # set when name is set
      field :file_name_length, 'S'
      # set when extra_field is set
      field :extra_field_length, 'S', :default => 0
      # set when file comment is set
      field :file_comment_length, 'S', :default => 0
      field :disk_number, 'S', :default => 0
      field :internal_file_attributes, 'S', :default => 0
      field :external_file_attributes, 'L', :default => 0
      field :local_file_header_offset, 'L'
      field :name, 'a*', :size => :file_name_length
      field :extra_field, 'a*', :size => :extra_field_length, :default => ''
      field :comment, 'a*', :default => '', :size => :file_comment_length, :default => ''
    end
  end
end
