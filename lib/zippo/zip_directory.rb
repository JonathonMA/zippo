require 'zippo/zip_member'
require 'zippo/central_directory_parser'

module Zippo
  class ZipDirectory
    def initialize io
      @io = io
    end
    def [](name)
      entries.detect {|x| x.name == name }
    end
    def entries
      CentralDirectoryParser.new(@io).cd_file_headers.map do |header|
        ZipMember.new @io, header
      end
    end
  end
end
