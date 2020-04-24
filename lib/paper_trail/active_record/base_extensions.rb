module PaperTrail::ActiveRecord

# Extensions to ActiveRecord::Base to better support PaperTrail
module BaseExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    # Versions for STI subclasses are included by default. Pass subclasses: false to *only* include
    # versions for the base class (no subclasses).
    def versions(subclasses: true)
      if self == base_class and subclasses
        Version.where(item_type: base_class.name)
      else
        Version.where(item_type: base_class.name, item_subtype: self.name)
      end.tap do |versions|
        PaperTrail::ActiveRecord.config.versions_extends.each do |mod|
          versions.extend(mod)
        end
      end
    end

    def find_deleted_version(id)
      Version.destroys.with_item_keys(base_class.name, id).first
    end

    def find_deleted_version!(id)
      Version.destroys.with_item_keys(base_class.name, id).first!
    end

    # Unlike find, does not raise RecordNotFound if not found
    def find_deleted(id)
      find_deleted_version(id)&.reify
    end

    def find_deleted!(id)
      find_deleted_version!(id).reify
    end

    def valid_versions_association_names
      [
        :versions,
        :versions_with_related,
        :versions_with_all_related,

        :related_versions,
        :all_related_versions,
      ]
    end
    def versions_association_names
      reflect_on_all_associations.map(&:name).grep(/versions/)
    end

    def has_many_versions(name, *args, **options)
      has_many name, *args, class_name: 'Version', extend: PaperTrail::ActiveRecord.config.versions_extends, **options
    end

    # Creates associations for finding related versions — that is, versions for related/children
    # records of this record, not just versions of this record itself.
    #
    # The way it finds those related associations is by querying the versions table on a "metadata"
    # column, for example user_id, instead of on item_id (which is what you use to get versions
    # directly for a particular record).
    #
    # foreign_key identifies which metadata column links versions for related/child records back
    # to the "parent" record.
    #
    # For example, to create a :versions_with_related association on User that finds all versions
    # that have changed a particular user record or any of its related/child records, configure
    # paper_trail for all related/child models with meta: :user_id, and then pass :user_id as the
    # foreign_key to has_related_versions.
    #
    def has_related_versions(foreign_key, item_types: nil)
      parent_model_name = name
      with_options(foreign_key: foreign_key) do |_|
        if item_types
          # self + filtered related records
          _.has_many_versions :versions_with_related, -> { where(arel_table[:item_type].in([parent_model_name] + item_types)) }
          #        filtered related records only (exclude self)
          _.has_many_versions :related_versions,      -> { where(arel_table[:item_type].in(                      item_types)) }
          has_versions_with_all_related foreign_key, 'all_'
        else
          # Not filtered by item_types, so just make the "all" association be the default instead of
          # defining 2 associations that are identical.
          has_versions_with_all_related foreign_key, ''
        end
      end
    end

    def has_versions_with_all_related(foreign_key, all_prefix)
      parent_model_name = name
      with_options(foreign_key: foreign_key) do |_|
        # self + all related records (any item_type)
        _.has_many_versions :"versions_with_#{all_prefix}related"
        #        all related records *only* (exclude self)
        _.has_many_versions :"#{all_prefix}related_versions", -> { where(arel_table[:item_type].not_eq(parent_model_name)) }
      end
    end
  end # module ClassMethods

  def created_version
    versions.creates.first
  end

  # Workaround to prevent paper_trail from incorrectly recording a change from new value to new value.
  # Useful if you've already set the attribute to the new value and now you want to save that change
  # to the database, with versioning.
  def paper_trail_update_column_using_value_from_changes(name, changes: changes(), touch: true)
    paper_trail_update_columns_using_value_from_changes name, changes: changes, touch: touch
  end

  # Tested by: spec/lib/active_record/base_extensions/paper_trail_extensions_spec.rb
  def paper_trail_update_columns_using_value_from_changes(*names, changes: changes(), touch: true)
    new_values = {}
    names.each do |name|
      (old_value, new_value = changes[name]) or next
      self.send("#{name}=", old_value)
      new_values[name] = new_value
    end
    new_values[:updated_at] = Time.now  if has_attribute?(:updated_at) && touch
    paper_trail.update_columns new_values
  end
end
end

ActiveRecord::Base.class_eval do
  include PaperTrail::ActiveRecord::BaseExtensions
end

