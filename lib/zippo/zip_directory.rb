require 'zippo/zip_member'
require 'zippo/central_directory_parser'
require 'forwardable'

module Zippo
  class ZipDirectory
    extend Forwardable
    include Enumerable
    def_delegator :entries, :empty?
    def_delegator :entries, :each
    def initialize io = nil
      @io = io
    end

    def [](name)
      entries.detect {|x| x.name == name }
    end

    def []=(name, string)
      insert(name, StringIO.new(string))
    end

    def insert(name, source)
      if source.is_a? ZipMember
        entries << source.with_name(name)
      elsif source.is_a? String
        entries << IOZipMember.new(name, File.open(source))
      else
        entries << IOZipMember.new(name, source)
      end
    end

    def entries
      @entries ||= if @io
        CentralDirectoryParser.new(@io).cd_file_headers.map do |header|
          ZipMember.new @io, header
        end
      else
        []
      end
    end
  end
end
