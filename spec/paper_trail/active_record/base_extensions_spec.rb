require 'spec_helper'

RSpec.describe PaperTrail::ActiveRecordExt::BaseExtensions do
  describe 'paper_trail_update_columns_using_value_from_changes' do
    let(:subject) { OpenStruct.new(a: 'new', updated_at: 'now', changes: {'a': ['old', 'new']}).tap {|subject|
      subject.singleton_class.include described_class
    } }
    it 'only updates columns that actually have changes' do
      expect(subject).to receive(:has_attribute?).with(:updated_at).and_return(false)
      double().tap do |paper_trail|
        expect(paper_trail).to receive(:update_columns).with({a: 'new'})
        expect(subject).to receive(:paper_trail).with(no_args).and_return(paper_trail)
      end

      subject.paper_trail_update_columns_using_value_from_changes :a, :b
    end

    it 'updates updated_at if has_attribute?(:updated_at) and touch: true (default)' do
      Timecop.freeze do
        expect(subject).to receive(:has_attribute?).with(:updated_at).and_return(true)
        double().tap do |paper_trail|
          expect(paper_trail).to receive(:update_columns).with({a: 'new', updated_at: Time.now})
          expect(subject).to receive(:paper_trail).with(no_args).and_return(paper_trail)
        end

        subject.paper_trail_update_columns_using_value_from_changes :a, :b
      end
    end
  end

  describe 'created_version' do
    it do
      record = Post.create!
      expect(record.created_version).to be_a Version
    end
  end

  describe '.versions' do
    it do
      record = Post.create!
      expect(Post.versions.last!).to be_a Version
    end
  end

  describe '.find_deleted_version/find_deleted' do
    it do
      record = Post.create!
      record.destroy
      expect(Post.find_deleted_version(record.id)).to be_a Version
      expect(Post.find_deleted        (record.id)).to be_a Post

      expect(Post.find_deleted_version(0)).to be_nil
      expect(Post.find_deleted        (0)).to be_nil
      expect{Post.find_deleted!       (0)}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe 'has_related_versions :user_id' do
    it do
      user = User.create!
      record = Post.create!(author: user)
      expect(user.versions_with_related).to contain_exactly(
        user.versions.creates.last,
        record.versions.creates.last,
      )
    end
  end
end
