require 'rails_helper'

RSpec.describe Api::AnotherArticlesController, type: :controller do
  render_views

  describe '#index' do
    let!(:article_1) { Article.create title: 'First article' }
    let!(:article_2) { Article.create title: 'Second article' }

    before { get :index, format: :json }

    it 'should return paginated collection' do
      expect(assigns(:articles).to_a).to eq [article_1, article_2]
      expect(JSON.parse(response.body)).to match_array([{ "id" => article_1.id, "title" => article_1.title }, { "id" => article_2.id, "title" => article_2.title }])
    end
  end

  describe '#show' do
    let!(:article_1) { Article.create title: 'First article' }

    before { get :show, params: { id: article_1.id }, format: :json }

    it 'should find article' do
      expect(assigns(:article)).to eq article_1
      expect(JSON.parse(response.body)).to eq({ "id" => article_1.id, "title" => article_1.title })
    end
  end

  describe '#create' do
    context 'when success' do
      let(:params) { { article: { title: 'First article' } } }

      before { post :create, params: params, format: :json }

      it 'should create new article and return article data' do
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).title).to eq('First article')
        expect(JSON.parse(response.body)).to eq({ "id" => Article.last.id, "title" => Article.last.title })
      end
    end

    context 'when article not valid' do
      let(:params) { { article: { title: '' } } }

      before { post :create, params: params, format: :json }

      it 'should return validation errors' do
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
        expect(JSON.parse(response.body)).to eq({ "errors" => { "title" => ["can't be blank"] } })
      end
    end
  end

  describe '#update' do
    let(:article_1) { Article.create title: 'First article' }

    context 'when success' do
      let(:params) { { title: 'First article - new name' } }

      before { put :update, params: { id: article_1.id, article: params }, format: :json }

      it 'should update article and return article data' do
        expect(assigns(:article).reload.title).to eq('First article - new name')
        expect(JSON.parse(response.body)).to eq({ "id" => article_1.id, "title" => 'First article - new name' })
      end
    end

    context 'when article not valid' do
      let(:params) { { title: '' } }

      before { put :update, params: { id: article_1.id, article: params }, format: :json }

      it 'should return validation errors' do
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
        expect(assigns(:article).reload.title).to eq('First article')
        expect(JSON.parse(response.body)).to eq({ "errors" => { "title" => ["can't be blank"] } })
      end
    end
  end

  describe '#destroy' do
    let(:article_1) { Article.create title: 'First article' }

    before { delete :destroy, params: { id: article_1.id }, format: :json }

    it 'should destroy article and return it data' do
      expect(Article.count).to eq 0
      expect(JSON.parse(response.body)).to eq({ "id" => article_1.id, "title" => article_1.title })
    end
  end
end
