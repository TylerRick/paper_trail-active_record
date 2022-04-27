require 'paper_trail/version_concern'

module PaperTrail::ActiveRecord
module VersionConcernExt
  extend ActiveSupport::Concern

  module ClassMethods
    # Returns versions before `obj`.
    # Same as preceding but uses lteq instead of lt
    #
    # @param obj - a `Version` or a timestamp
    # @param timestamp_arg - boolean - When true, `obj` is a timestamp.
    #   Default: false.
    # @return `ActiveRecord::Relation`
    # @api public
    def preceding_inclusive(obj, timestamp_arg = false)
      if timestamp_arg != true && primary_key_is_int?
        return where(arel_table[primary_key].lteq(obj.id)).order(arel_table[primary_key].desc)
      end

      obj = obj.send(:created_at) if obj.is_a?(self)
      where(arel_table[:created_at].lteq(obj)).
        order(timestamp_sort_order("desc"))
    end

    # Same as between but uses gteq/lteq instead of gt/lt
    def between_inclusive(start_time, end_time)
      where(
        arel_table[:created_at].gteq(start_time).
        and(arel_table[:created_at].lteq(end_time))
      ).order(timestamp_sort_order)
    end
  end

  included do
    # Finds versions that had made changes to object on *all* of the given attributes.
    #
    # Like built-in where_object_changes but without specifying a value. where_object_changes
    # apparently can only be used to find where a given attribute was changed to or from a specific
    # *value*. But sometimes you don't care which value it changed to or from, you just want to find
    # where it changed at all.
    scope :where_object_changed, ->(*attr_names) {
      attr_names.inject(all) do |relation, attr_name|
        relation.where("object_changes->>#{connection.quote(attr_name)} is not null")
      end
    }

    # Finds versions that had made changes to object on *any* of the given attributes.
    scope :where_object_changed_any, ->(*attr_names) {
      where_clause = attr_names.
        map {|attr_name| "object_changes->>#{connection.quote(attr_name)} is not null" }.
        join(' OR ')
      where(where_clause)
    }
  end

  def action
    case event
    when 'update'
      "updated"
    when 'create'
      "created"
    else
      "#{event}ed"
    end
  end

  def item_class
    item_type.safe_constantize
  end
end
end

PaperTrail::VersionConcern.class_eval do
  prepend PaperTrail::ActiveRecord::VersionConcernExt
  include PaperTrail::ActiveRecord::VersionConcernExt
end

