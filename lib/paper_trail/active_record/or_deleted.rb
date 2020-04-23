module PaperTrail::ActiveRecord

# If you include this module into a model, it will automatically add a `{association}_or_deleted`
# method for every `belongs_to` or `has_one` association that is defined.
#
# Because it reflects on all associations on that model as soon as it is included, make sure to
# include it *after* all of your associations are defined.
#
# If you want more control, and don't want it to add anything automatically, you can manually call
# `define_assoc_or_deleted :association` for each association that you want to have a
# `{association}_or_deleted` method.
#
# If you want it to automatically be added for all assocations on *all* application models, you can
# use [gem 'active_record_include'](https://github.com/TylerRick/active_record_include) like this:
#
#   class ApplicationRecord < ActiveRecord::Base
#     include_when_connected PaperTrail::ActiveRecord::OrDeleted
module OrDeleted
  extend ActiveSupport::Concern

  module ClassMethods
    # Defines a `{association}_or_deleted` method for the given association. This method will call
    # the usual association method to try to find the associated record but if that returns nil,
    # will fall back to looking for a deleted record from the `versions` history (using
    # `klass.find_deleted`).
    #
    # You can replace the `or_deleted` part with a different suffix using `suffix:` option.
    #
    # You can even give it the same name as the existing association method if you want to override
    # the existing method with one that always falls back to looking for a deleted record.
    #
    # class Post
    #   belongs_to :author
    #   # overrides author method with a version that finds deleted if not found
    #   define_assoc_or_deleted :author, suffix: nil
    #
    def define_assoc_or_deleted(assoc_name, suffix: 'or_deleted')
      reflection = reflect_on_association(assoc_name) or raise(ArgumentError, "can't find reflection for #{assoc_name}")
      method_name = suffix ? "#{assoc_name}_#{suffix}" : assoc_name
      #begin
      #  puts "Creating #{self.name}.#{method_name}  =>  #{reflection.klass}.find_deleted(#{reflection.foreign_key})"

      prepend(Module.new do
        define_method method_name do |*args|
          orig_value =
            if defined?(super)
              super(*args)
            else
              public_send(reflection.name, *args)
            end
          return orig_value if orig_value

          klass =
            if reflection.polymorphic?
              public_send(reflection.foreign_type).constantize
            else
              reflection.klass
            end
          id = public_send(reflection.foreign_key)

          klass.find_deleted(id)
        end
      end)

      #rescue
      #  puts "Rescued for #{self.name}.#{reflection.inspect}: #{$!} from #{$!.backtrace.first(5)}"
      #end
    end

    def define_assoc_or_deleted_on_all_associations(suffix: 'or_deleted')
      reflect_on_all_associations.each do |reflection|
        puts %(#{self}.reflection.name=#{(reflection.name).inspect})
        next if reflection.collection?

        assoc_name = reflection.name
        method_name = suffix ? "#{assoc_name}_#{suffix}" : assoc_name
        next if method_defined?(method_name)

        define_assoc_or_deleted reflection.name, suffix: suffix
      end
    end
  end

  included do
    define_assoc_or_deleted_on_all_associations
  end
end
end
