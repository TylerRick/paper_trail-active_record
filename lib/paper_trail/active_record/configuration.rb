module PaperTrail
  module ActiveRecordExt
    class Configuration
      def initialize
        config = self

        config.versions_extends = []
      end

      # Causes methods that return a collection of Versions to automatically extend these modules.
      #   config.versions_extends = [Versions]
      attr_accessor :versions_extends
    end
  end
end
