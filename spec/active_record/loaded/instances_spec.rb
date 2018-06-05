require 'spec_helper'

RSpec.describe ActiveRecord::Loaded::Instances do
  it 'has a version number' do
    expect(ActiveRecord::Loaded::Instances::VERSION).not_to be nil
  end

  describe '#loaded_instances' do
    context 'user with 2 posts' do
      let(:user) { User.create(name: 'buya') }
      let(:posts) { [Post.create(user: user, text: 'buya p1'), Post.create(user: user, text: 'buya p1')] }
      before do
        posts
      end

      context 'only user is loaded' do
        before { user.reload }

        it 'only returns the user instance' do
          expect(user.loaded_instances).to contain_exactly(user)
        end
      end

      context 'user and posts loaded' do
        before { user.reload.posts.load }

        it 'returns the user and post instances' do
          expect(user.loaded_instances).to contain_exactly(user, *posts)
        end
      end

      context 'one post loaded' do
        let(:post) { posts.first.reload }

        it 'returns the user and post instances' do
          expect(post.loaded_instances).to contain_exactly(post)
        end
      end

      context 'one post and user loaded' do
        let(:post) { posts.first.reload }
        before { post.user }

        it 'returns the user and post instances' do
          expect(post.loaded_instances).to contain_exactly(post, user)
        end
      end

      context 'one post and user whos posts are loaded' do
        let(:post) { posts.first.reload }
        before { post.user.posts.load }

        it 'returns the user and post instances' do
          expect(post.loaded_instances).to contain_exactly(user, *posts)
        end
      end
    end
  end
end
