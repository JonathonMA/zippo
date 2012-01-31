module Zippo
  class ZipFileWriter
    def initialize(directory, filename)
      @directory = directory
      @filename = filename
    end
    def write
      for member in @directory
        # output local file header
        # output compressed member data
      end
      for member in @directory
        # output central directory header
      end
      # output end of central directory record
    end
  end
end
