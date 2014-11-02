require 'zippo/filter/base'

module Zippo::Filter
  # An Uncompressor is responsible for reading (and likely
  # uncompressing) member data from a Zip file.
  #
  # @example Obtaining an uncompressor
  #   compression_method = 8
  #   uncompressor = Uncompressor.for(compression_method).new(io)
  #   uncompressor.uncompress_to out
  #
  # Subclasse should include a METHOD constant to indicate
  # which zip compression method they handle. The actual
  # uncompression should be implemented in the filter and
  # tail_filter methods.
  class Uncompressor
    include Zippo::Filter::Base

    # @param [IO] io the IO the member data is located in
    # @param [Integer] compressed_size the compressed size of the data
    def initialize(io, compressed_size)
      # XXX should probably capture the offset here
      #     current usage assumes the IO has already been positioned at
      #     the appropriate location
      @io = io
      @compressed_size = compressed_size
      @remaining = @compressed_size
    end

    def read(n, buf = nil)
      if @remaining >= n
        @remaining -= n
      elsif (n = @remaining) > 0
        @remaining = 0
      else
        return nil
      end

      @io.read n, buf
      buf.replace filter(buf)
    end

    # Uncompresses the data to the specified IO
    #
    # @param [IO] io the object to uncompress to, must respond to #<<
    def uncompress_to(io)
      buf = ""
      io << buf while read BLOCK_SIZE, buf
      io << tail_filter
    end

    # @return [String] the uncompressed data
    def uncompress
      uncompress_to ""
    end
  end
end
