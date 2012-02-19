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
    # 256k block size seems to perform well in testing
    BLOCK_SIZE = 1 << 18
    module ClassMethods
      def filters
        @filters_hash ||= Hash[@filters.map{|u| [u::METHOD, u]}]
      end
      def for(method)
        return filters[method] if filters[method]
        raise "unknown compression method #{method}"
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
