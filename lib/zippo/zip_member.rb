module Zippo
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
