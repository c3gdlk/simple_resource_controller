require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  render_views

  let!(:current_user) { User.create name: 'Bob' }
  let!(:another_user) { User.create name: 'Rob' }

  describe '#index' do
    let!(:article_1) { current_user.articles.create title: 'First article' }
    let!(:article_2) { another_user.articles.create title: 'Second article' }

    context 'default' do
      before { get :index }

      it 'should return paginated collection' do
        expect(response).to render_template(:index)
        expect(assigns(:articles).to_a).to eq [article_1]
      end
    end

    context 'has sope' do
      let!(:article_3) { current_user.articles.create title: 'Third article' }
      let!(:article_4) { current_user.articles.create title: 'Fourth article' }

      before { get :index, params: { recent: true } }

      it 'should return last 2 articles ordered by created_at' do
        expect(response).to render_template(:index)
        expect(assigns(:articles).to_a).to eq [article_4,article_3]
      end
    end
  end

  describe '#show' do
    context 'when need to open current_user article' do
      let!(:article_1) { current_user.articles.create title: 'First article' }

      before { get :show, params: { id: article_1.id } }

      it 'should find current_user article' do
        expect(response).to render_template(:show)
        expect(assigns(:article)).to eq article_1
      end
    end

    context 'when need to open another_user article' do
      let!(:article_1) { another_user.articles.create title: 'First article' }

      it 'should find current_user article' do
        expect { get :show, params: { id: article_1.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#new' do
    before { get :new }

    it 'should render form and assign new article to the current user' do
      expect(response).to render_template(:new)
      expect(assigns(:article)).to be_kind_of(Article)
      expect(assigns(:article).user).to eq(current_user)
    end
  end

  describe '#create' do
    context 'when success' do
      let(:params) { { article: { title: 'First article' } } }

      before { post :create, params: params }

      it 'should create new article and redirect to articles path' do
        expect(response).to redirect_to(articles_path)
        expect(flash[:notice]).to eq 'A new article was created'
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).user).to eq(current_user)
        expect(assigns(:article).title).to eq('First article')
      end
    end

    context 'when article not valid' do
      let(:params) { { article: { title: '' } } }

      before { post :create, params: params }

      it 'should create new article and redirect to articles path' do
        expect(response).to render_template(:new)
        expect(flash[:notice]).to eq nil
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).user).to eq(current_user)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
      end
    end

    context 'when some ActiveRecord magic happened' do
      let(:params) { { article: { title: '' } } }

      before do
        allow_any_instance_of(Article).to receive(:valid?).and_return(true)
        allow_any_instance_of(Article).to receive(:save).and_return(false)
      end

      it 'should create new article and redirect to articles path' do
        expect { post :create, params: params }.to raise_error('Too many Rails magic. Please check your code')
      end
    end
  end

  describe '#edit' do
    context 'when current_user article' do
      let(:article_1) { current_user.articles.create title: 'First article' }

      before { get :edit, params: { id: article_1.id } }

      it 'should render form' do
        expect(response).to render_template(:edit)
        expect(assigns(:article)).to eq(article_1)
      end
    end

    context 'when another_user article' do
      let(:article_1) { another_user.articles.create title: 'First article' }

      it 'should raise error' do
        expect { get :edit, params: { id: article_1.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#update' do
    let(:article_1) { current_user.articles.create title: 'First article' }

    context 'when success' do
      let(:params) { { title: 'First article - new name' } }

      before { put :update, params: { id: article_1.id, article: params } }

      it 'should update article and redirect to articles path' do
        expect(response).to redirect_to(articles_path)
        expect(flash[:notice]).to eq 'Article was updated'
        expect(assigns(:article).reload.title).to eq('First article - new name')
      end
    end

    context 'when article not valid' do
      let(:params) { { title: '' } }

      before { put :update, params: { id: article_1.id, article: params } }

      it 'should create new article and redirect to articles path' do
        expect(response).to render_template(:edit)
        expect(flash[:notice]).to eq nil
        expect(assigns(:article)).to be_kind_of(Article)
        expect(assigns(:article).user).to eq(current_user)
        expect(assigns(:article).valid?).to be_falsey
        expect(assigns(:article).errors.full_messages).to eq(["Title can't be blank"])
        expect(assigns(:article).reload.title).to eq('First article')
      end
    end

    context 'when another_user article' do
      let(:article_1) { another_user.articles.create title: 'First article' }

      it 'should raise error' do
        expect { put :update, params: { id: article_1.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#destroy' do
    context 'when current_user article' do
      let(:article_1) { current_user.articles.create title: 'First article' }

      before { delete :destroy, params: { id: article_1.id } }

      it 'should render form' do
        expect(response).to redirect_to(articles_path)
        expect(flash[:danger]).to eq 'Article was removed'
        expect(Article.count).to eq 0
      end
    end

    context 'when another_user article' do
      let(:article_1) { another_user.articles.create title: 'First article' }

      it 'should raise error' do
        expect { delete :destroy, params: { id: article_1.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
