module Zippo
  class Uncompressor
    def initialize(io, compressed_size)
      @io = io
      @compressed_size = compressed_size
    end
    def read n
      @io.read n
    end
    protected :read
    @@uncompressors = []
    def self.uncompressors
      @@uncompressors_hash ||= Hash[@@uncompressors.map{|u| [u::METHOD, u]}]
    end
    def self.for(method)
      return uncompressors[method] if uncompressors[method]
      raise "unknown compression method #{method}"
    end

    def self.inherited(klass)
      @@uncompressors << klass
    end
  end
end
