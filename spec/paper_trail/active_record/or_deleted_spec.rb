require 'spec_helper'

RSpec.describe PaperTrail::ActiveRecord::OrDeleted do
  describe 'author_or_deleted' do
    it do
      user = User.create!
      record = Post.create!(author: user)
      user.destroy
      record.reload_author
      expect(record.author).to be_nil
      expect(record.author_or_deleted).to eq user
    end
  end
end

