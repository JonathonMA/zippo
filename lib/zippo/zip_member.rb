require 'zippo/local_file_header'
require 'zippo/filter/uncompressors'
require 'zippo/filter/compressors'

require 'forwardable'

module Zippo
  # A member of a Zip archive file.
  class ZipMember
    def initialize io, header
      @io = io
      @header = header
    end

    # @return [String] the name of the member
    def name
      @name ||= @header.name
    end

    # @return [Boolean] True if the member is a directory, False
    #   otherwise
    def directory?
      name.end_with? '/'
    end

    extend Forwardable
    def_delegators :@header, :crc32, :compressed_size, :uncompressed_size, :compression_method

    # Reads (and possibly uncompresses) the member's data
    #
    # @return [String] the uncompressed member data
    def read
      seek_to_compressed_data
      uncompressor.uncompress
    end

    # Duplicates this zip member and overrides the name.
    #
    # @param [String] name the name to use
    # @return [ZipMember] the new ZipMember
    def with_name name
      dup.tap do |obj|
        obj.instance_variable_set :@name, name
      end
    end

    # Writes the member data to the specified IO using the specified
    # compression method.
    #
    # @param [IO] out the IO to write to
    # @param [Integer] preferred_method the compression method to use
    # @param [Boolean] recompress whether or not to recompress the data
    #
    # @return [Integer, Integer, Integer] the amount written, the
    #   original size of the data, the crc32 of the data
    def write_to out, preferred_method = Filter::DeflateCompressor::METHOD, recompress = false
      seek_to_compressed_data
      if recompress
        Filter::Compressor.for(preferred_method).new(uncompressor).compress_to(out)
      else
        IO.copy_stream @io, out, @header.compressed_size
        return @header.compressed_size, @header.uncompressed_size, @header.crc32
      end
    end

    private
    def local_file_header
      @io.seek @header.local_file_header_offset
      LocalFileHeader::Unpacker.new(@io).unpack
    end

    def seek_to_compressed_data
      @io.seek @header.local_file_header_offset + local_file_header.size
    end

    def uncompressor
      Filter::Uncompressor.for(@header.compression_method).new(@io, @header.compressed_size)
    end

    def compressed_member_data
      seek_to_compressed_data
      @io.read @header.compressed_size
    end
  end
end
