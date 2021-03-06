require 'rails_helper'

RSpec.describe RecentCommentsController, type: :controller do
  render_views

  describe '#index' do
    let!(:article_1) { Article.create title: 'Test Article' }
    let!(:article_2) { Article.create title: 'Another Article' }
    let!(:comment_1) { article_1.comments.create body: 'Comment 1', created_at: 2.days.ago }
    let!(:comment_2) { article_1.comments.create body: 'Comment 2' }
    let!(:comment_3) { article_2.comments.create body: 'Comment 3' }

    before { get :index, params: { article_id: article_1.id } }

    it 'should return paginated collection' do
      expect(response).to render_template(:index)
      expect(assigns(:comments).to_a).to eq [comment_2]
    end
  end
end
