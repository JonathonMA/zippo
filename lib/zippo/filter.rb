module Zippo
  module NullFilters
    def filter(buf)
      buf
    end

    def tail_filter
      ""
    end
  end

  module Filter
    # Use same block size as rubyzip for better comparison
    BLOCK_SIZE = 131072
    module ClassMethods
      def filters
        @filters_hash ||= Hash[@filters.map{|u| [u::METHOD, u]}]
      end
      def for(method)
        filters[method] or raise "unknown compression method #{method}"
      end

      def inherited(klass)
        @filters << klass
      end
    end
    def self.included(base)
      base.class_eval do
        @filters = []
        extend ClassMethods
      end
    end
  end
end
