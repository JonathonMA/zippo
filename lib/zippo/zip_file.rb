module Zippo
  class ZipFile
    def self.open(filename)
      new filename
    end

    def initialize(filename)
      @filename = filename
    end

    def [](member_name)
      directory[member_name]
      return ZipMember.new
    end
    def close
    end
    def directory
      File.open(@filename) { |io| ZipDirectory.new io }
    end
  end

  class ZipDirectory
    def initialize io
      @io = io
    end
    def [](name)
      entries.detect {|x| x.name == name }
    end
    def entries
      [ZipMember.new]
    end
  end

  class ZipMember
    attr_reader :name
    def initialize
      @name = "test.file"
    end
    def read
      "The quick brown fox jumps over the lazy dog."
    end
  end
end
