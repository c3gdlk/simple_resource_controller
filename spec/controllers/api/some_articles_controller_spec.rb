require 'rails_helper'

RSpec.describe Api::SomeArticlesController, type: :controller do
  render_views

  describe '#index' do
    let!(:article_1) { Article.create title: 'First article' }
    let!(:article_2) { Article.create title: 'Second article' }

    before { get :index, format: :json }

    it 'should return collection serialized with AnotherArticleSerializer' do
      expect(JSON.parse(response.body).map { |row| row["created_at"] }.compact.count).to eq(2)
    end
  end

  describe '#index2' do
    let!(:article_1) { Article.create title: 'First article' }
    let!(:article_2) { Article.create title: 'Second article' }

    before { get :index2, format: :json }

    it 'should return collection serialized with SomeArticleSerializer' do
      expect(JSON.parse(response.body).map { |row| row["updated_at"] }.compact.count).to eq(2)
    end
  end

  describe '#show' do
    let!(:article_1) { Article.create title: 'First article' }

    before { get :show, params: { id: article_1.id }, format: :json }

    it 'should return article serialized with AnotherArticleSerializer' do
      expect(JSON.parse(response.body)["created_at"]).to be_present
    end
  end

  describe '#show2' do
    let!(:article_1) { Article.create title: 'First article' }

    before { get :show2, params: { id: article_1.id }, format: :json }

    it 'should return article serialized with SomeArticleSerializer' do
      expect(JSON.parse(response.body)["updated_at"]).to be_present
    end
  end

  describe '#create' do
    context 'when success' do
      let(:params) { { article: { title: 'First article' } } }

      before { post :create, params: params, format: :json }

      it 'should return article serialized with AnotherArticleSerializer' do
        expect(JSON.parse(response.body)["created_at"]).to be_present
      end
    end
  end

  describe '#update' do
    let(:article_1) { Article.create title: 'First article' }

    context 'when success' do
      let(:params) { { title: 'First article - new name' } }

      before { put :update, params: { id: article_1.id, article: params }, format: :json }

      it 'should return article serialized with AnotherArticleSerializer' do
        expect(JSON.parse(response.body)["created_at"]).to be_present
      end
    end
  end

  describe '#destroy' do
    let(:article_1) { Article.create title: 'First article' }

    before { delete :destroy, params: { id: article_1.id }, format: :json }

    it 'should return article serialized with AnotherArticleSerializer' do
      expect(JSON.parse(response.body)["created_at"]).to be_present
    end
  end
end
