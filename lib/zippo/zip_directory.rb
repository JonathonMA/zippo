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
      [ ZipMember.new ]
    end
  end
end
