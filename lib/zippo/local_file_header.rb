require 'zippo/binary_structure'

module Zippo
  # Represents a local file header as documented in APPNOTE.TXT
  # @see http://www.pkware.com/documents/casestudies/APPNOTE.TXT
  class LocalFileHeader
    SIGNATURE = 0x04034b50
    binary_structure do
      # @!macro [attach] bs.field
      #   @!attribute [rw] $1
      field :signature, 'L', signature: SIGNATURE
      field :version_extractable_by, 'S', default: 20
      field :bit_flags, 'S', default: 0
      field :compression_method, 'S'
      field :last_modified_time, 'S', default: 0 # XXX
      field :last_modified_date, 'S', default: 0 # XXX
      field :crc32, 'L'
      field :compressed_size, 'L'
      field :uncompressed_size, 'L'
      # set when name is set
      field :file_name_length, 'S'
      # set when extra_field is set
      field :extra_field_length, 'S', default: 0
      field :name, 'a*', size: :file_name_length
      field :extra_field, 'a*', default: '', size: :extra_field_length
    end
  end
end
