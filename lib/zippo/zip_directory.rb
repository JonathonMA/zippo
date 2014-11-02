require 'zippo/zip_member'
require 'zippo/io_zip_member'
require 'zippo/central_directory_reader'
require 'forwardable'

module Zippo
  # The ZipDirectory is responsible for managing the set of ZipMembers
  # belonging to a ZipFile.
  class ZipDirectory
    extend Forwardable
    include Enumerable
    # should delegate to entries_hash instead of entries whenever we can
    def_delegators :entries_hash, :empty?
    def_delegators :entries, :each, :map

    def initialize(io = nil)
      @io = io
    end

    # @param [String] name the name of the ZipMember
    # @return [ZipMember] the ZipMember with the specified name
    def [](name)
      entries_hash[name]
    end

    # Inserts data into the ZipFile
    #
    # @param [String] name the name of the member to insert
    # @param [String] data the data to insert
    def []=(name, data)
      insert(name, StringIO.new(data))
    end

    # Inserts data into the ZipFile
    #
    # - when the source is a ZipMember, the already-compressed data may
    #   be re-used when writing out
    # - when the source is a String, it is interpreted as a filename,
    #   and will be used as the source of the data
    # - otherwise, source is assumed to an already opened IO object
    #
    # @param [String] name the name of the member to insert
    # @param source where to read the data from
    #
    # Source can be any of
    # - an IO object
    # - a string (path to file)
    # - another ZipMember (allowing direct stream copy)
    def insert(name, source)
      set name,
          case source
          when ZipMember then source.with_name name
          when String then IOZipMember.new name, File.open(source, 'r:BINARY')
          else IOZipMember.new name, source
          end
    end

    # @return [Hash] the hash of ZipMembers, the hash key is the
    #   member's name
    def entries_hash
      @entries_hash ||=
        if @io
          CentralDirectoryReader.new(@io)
            .cd_file_headers.each_with_object({}) do |header, hash|
              hash[header.name] = ZipMember.new @io, header
            end
        else
          {}
        end
    end

    # @return [Array] the members of the ZipFile
    def entries
      entries_hash.values
    end

    private

    def set(name, member)
      entries_hash[name] = member
    end
  end
end
