ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string 'content'
    t.string 'category'
    t.integer 'author_id'
  end

  create_table :users, force: true do |t|
    t.string 'name'
  end

  create_table "versions", force: true do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.datetime "created_at", null: false
    if $db == 'pg'
      t.jsonb 'object'
      t.jsonb 'object_changes'
    else
      t.text 'object'
      t.text 'object_changes'
    end
    t.integer 'user_id'
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Version < ApplicationRecord
  include PaperTrail::VersionConcern
end

class User < ApplicationRecord
  has_paper_trail(
    versions: {
      class_name: 'Version',
    },
    meta: {
      user_id: :id,
    }
  )
  has_related_versions :user_id
end

class Post < ApplicationRecord
  has_paper_trail(
    versions: {
      class_name: 'Version',
    },
    meta: {
      user_id: :author_id,
    }
  )

  belongs_to :author, class_name: 'User'
  include PaperTrail::ActiveRecord::OrDeleted
end
