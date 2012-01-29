require 'zippo/zip_member'
require 'zippo/central_directory_parser'
require 'forwardable'

module Zippo
  class ZipDirectory
    extend Forwardable
    def_delegator :entries, :empty?
    def initialize io = nil
      @io = io
    end
    def [](name)
      entries.detect {|x| x.name == name }
    end
    def insert_zip_member name, data
      entries << ZipMember.with_name_and_data(name, data)
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
