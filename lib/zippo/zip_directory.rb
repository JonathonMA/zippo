require 'zippo/zip_member'

module Zippo
  class ZipDirectory
    def initialize io
      @io = io
    end
    def [](name)
      entries.detect {|x| x.name == name }
    end
    def entries
      # XXX just getting tests passing
      Array.new CentralDirectoryParser.new(@io).end_of_cd_record.total_records, ZipMember.new
    end
  end
end
