require 'zippo/zip_member'
require 'zippo/io_zip_member'
require 'zippo/central_directory_parser'
require 'forwardable'

module Zippo
  class ZipDirectory
    extend Forwardable
    include Enumerable
    # should delegate to entries_hash instead of entries whenever we can
    def_delegators :entries_hash, :empty?
    def_delegators :entries, :each, :map

    def initialize io = nil
      @io = io
    end

    def [](name)
      entries_hash[name]
    end

    def []=(name, string)
      insert(name, StringIO.new(string))
    end

    # insert name, ZipMember to support copying zip data directly
    # insert name, String to insert the contents of a file
    # insert name, IO to insert the contents of an IO object
    def insert(name, source)
      set name,
        case source
        when ZipMember then source.with_name name
        when String then IOZipMember.new name, File.open(source, 'r:BINARY')
        else IOZipMember.new name, source
        end
    end

    def entries_hash
      @entries_hash ||= if @io
        {}.tap do |hash|
          CentralDirectoryParser.new(@io).cd_file_headers.each do |header|
            hash[header.name] = ZipMember.new @io, header
          end
        end
      else
        {}
      end
    end

    def entries
      entries_hash.values
    end

    private
    def set(name, member)
      entries_hash[name] = member
    end
  end
end
