require 'active_record'
require 'paper_trail'
require 'paper_trail/frameworks/active_record'

require_relative 'active_record/version'

require_relative 'active_record/configuration'
require_relative 'active_record/base_extensions'
require_relative 'active_record/or_deleted'
require_relative 'active_record/version_extensions'

module PaperTrail
  module ActiveRecord
    class << self
      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :config, :configuration

      def configure
        yield config
      end
    end
  end
end
