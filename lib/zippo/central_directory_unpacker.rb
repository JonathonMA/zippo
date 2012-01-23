require 'zippo/binary_structure'

module Zippo
  class EndCdRecord < BinaryStructure
    SIGNATURE = 0x06054b50
    PACKED_SIGNATURE = [SIGNATURE].pack('L')
    MAX_COMMENT_LENGTH = 1<<16
    field :signature, 'L', :default => SIGNATURE
    field :disk, 'S', :default => 0
    field :cd_disk, 'S', :default => 0
    field :records, 'S'
    field :total_records, 'S'
    field :cd_size, 'L'
    field :cd_offset, 'L'
    field :comment_length, 'S', :default => 0
    field :comment, 'a*', :default => "", :length => :comment_length
  end

  class CentralDirectoryUnpacker < BinaryUnpacker
    unpacks EndCdRecord
  end
end
