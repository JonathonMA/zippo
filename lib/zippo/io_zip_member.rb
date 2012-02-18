require 'zippo/compressor'
require 'zippo/compressor/deflate' # XXX only used for the default method

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

    def write_to out, preferred_compression_method = DeflateCompressor::METHOD, recompress = nil
      Compressor.for(preferred_compression_method).new(@source).compress_to(out)
    end
  end
end
