module Zippo
  class IOZipMember
    attr_reader :name

    def initialize(name, source)
      @name = name
      @source = source
    end

    def read
      @source.read
    ensure
      @source.rewind
    end

    def write_to io
      size = io.write read
      return size, size, Zlib.crc32(read)
    end
  end
end
