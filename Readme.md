# PaperTrail::ActiveRecord

[![Gem Version][1]][2]

An extension to [PaperTrail](https://github.com/paper-trail-gem/paper_trail)
that adds some useful extensions to models that have `has_paper_trail` and to the Version model.

## Methods added to models with `has_paper_trail`

- `.versions`
- `.find_deleted_version`
- `.find_deleted`
- `.has_many_versions`
- `.has_related_versions`
- `.has_versions_with_all_related`
- `created_version`
- `paper_trail_update_column_using_value_from_changes`
- `paper_trail_update_columns_using_value_from_changes`

## Methods added to `PaperTrail::Version` (`VersionConcern`)

- `.preceding_inclusive`
- `.between_inclusive`
- `scope :where_object_changed`
- `scope :where_object_changed_any`
- `#action`
- `#item_class`

## `OrDeleted`

If you include this module into a model, it will automatically add a `{association}_or_deleted`
method for every `belongs_to` or `has_one` association that is defined.

Because it reflects on all associations on that model as soon as it is included, make sure to
include it *after* all of your associations are defined.

If you want more control, and don't want it to add anything automatically, you can manually call
`define_assoc_or_deleted :association` for each association that you want to have a
`{association}_or_deleted` method.

If you want it to automatically be added for all assocations on *all* application models, you can
use [gem 'active_record_include'](https://github.com/TylerRick/active_record_include) like this:

``ruby
  class ApplicationRecord < ActiveRecord::Base
    include_when_connected PaperTrail::ActiveRecord::OrDeleted
```

### `def define_assoc_or_deleted(assoc_name, suffix: nil)`

Defines a `{association}_or_deleted` method for the given association. This method will call
the usual association method to try to find the associated record but if that returns nil,
will fall back to looking for a deleted record from the `versions` history (using
`klass.find_deleted`).

You can replace the `or_deleted` part with a different suffix using `suffix:` option.

You can even give it the same name as the existing association method if you want to override
the existing method with one that always falls back to looking for a deleted record.

```ruby
class Post
  belongs_to :author
  # overrides author method with a version that finds deleted if not found
  define_assoc_or_deleted :author, suffix: nil
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paper_trail-active_record'
```

And then execute:

    $ bundle

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/TylerRick/paper_trail-active_record.

[1]: https://badge.fury.io/rb/paper_trail-active_record.svg
[2]: https://rubygems.org/gems/paper_trail-active_record
