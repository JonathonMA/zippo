module Zippo
  module Filter
    # Mixin for a no-op filter.
    module NullFilters
      protected

      def filter(buf)
        buf
      end

      def tail_filter
        ""
      end
    end
  end
end
