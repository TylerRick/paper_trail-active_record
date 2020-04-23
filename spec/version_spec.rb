require 'spec_helper'

RSpec.describe Version do
  describe '.preceding_inclusive' do
    it do
      record = Post.create!
      record.update(content: 'new')
      version = record.versions.last
      expect(Version.preceding_inclusive(version).first).to eq version
      expect(Version.preceding(          version).first).to_not eq version
      expect(Version.preceding(          version).first.id).to be <(version.id)
    end
  end

  describe '.between_inclusive' do
    it do
      record = Post.create!
      version = record.versions.last
      expect(Version.between_inclusive(Time.now - 10, Time.now).last).to eq version
    end
  end

  if $db == 'pg'
    describe 'scope :where_object_changed' do
      it do
        record = Post.create!
        record.update(content: 'new')
        version = Post.versions.updates.where_object_changed(:content).last
        expect(version.changeset).to match({content: [nil, 'new']})

        version = Post.versions.updates.where_object_changed(:content, :category).last
        expect(version).to eq nil
      end
    end

    describe 'scope :where_object_changed_any' do
      it do
        record = Post.create!
        record.update(content: 'new')
        version = Post.versions.updates.where_object_changed_any(:content, :category).last
        expect(version.changeset).to match({content: [nil, 'new']})
      end
    end
  end

  describe '#action' do
    it do
      record = Post.create!
      version = record.versions.last
      expect(version.action).to eq 'created'
    end
  end

end

