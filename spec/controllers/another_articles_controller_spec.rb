require 'rails_helper'

RSpec.describe AnotherArticlesController, type: :controller do
  render_views

  describe '#index' do
    let!(:article_1) { Article.create title: 'First article' }
    let!(:article_2) { Article.create title: 'Second article' }

    before { get :index }

    it 'should return paginated collection' do
      expect(response).to render_template(:index)
      expect(assigns(:articles).to_a).to eq [article_1, article_2]
    end
  end

  describe '#show' do
    let!(:article_1) { Article.create title: 'First article' }

    before { get :show, id: article_1.id }

    it 'should find current_user article' do
      expect(response).to render_template(:show)
      expect(assigns(:article)).to eq article_1
    end
  end

  describe '#new' do
    before { get :new }

    it 'should render form and assign new article to the current user' do
      expect(response).to render_template(:new)
      expect(assigns(:article)).to be_kind_of(Article)
    end
  end

  describe '#create' do
    context 'when success' do
      let(:params) { { article: { title: 'First article' } } }

      before { post :create, params }

      it 'should create new article and redirect to articles path' do
        expect(response).to redirect_to(admin_articles_path)
        expect(flash[:notice]).to eq 'Saved!'
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).title).to eq('First article')
      end
    end

    context 'when article not valid' do
      let(:params) { { article: { title: '' } } }

      before { post :create, params }

      it 'should create new article and redirect to articles path' do
        expect(response).to render_template(:new)
        expect(flash[:notice]).to eq nil
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
      end
    end
  end

  describe '#edit' do
    let(:article_1) { Article.create title: 'First article' }

    before { get :edit, id: article_1.id }

    it 'should render form' do
      expect(response).to render_template(:edit)
      expect(assigns(:article)).to eq(article_1)
    end
  end

  describe '#update' do
    let(:article_1) { Article.create title: 'First article' }

    context 'when success' do
      let(:params) { { title: 'First article - new name' } }

      before { put :update, id: article_1.id, article: params }

      it 'should update article and redirect to articles path' do
        expect(response).to redirect_to(admin_articles_path)
        expect(flash[:notice]).to eq 'Saved!'
        expect(assigns(:article).reload.title).to eq('First article - new name')
      end
    end

    context 'when article not valid' do
      let(:params) { { title: '' } }

      before { put :update, id: article_1.id, article: params }

      it 'should create new article and redirect to articles path' do
        expect(response).to render_template(:edit)
        expect(flash[:notice]).to eq nil
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
        expect(assigns(:article).reload.title).to eq('First article')
      end
    end
  end

  describe '#destroy' do
    let(:article_1) { Article.create title: 'First article' }

    before { delete :destroy, id: article_1.id }

    it 'should render form' do
      expect(response).to redirect_to(admin_articles_path)
      expect(flash[:danger]).to eq nil
      expect(Article.count).to eq 0
    end
  end
end
