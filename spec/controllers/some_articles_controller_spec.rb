require 'rails_helper'

RSpec.describe SomeArticlesController, type: :controller do
  render_views

  describe '#new' do
    before { get :new }

    it 'should render form' do
      expect(response).to render_template(:new)
      expect(assigns(:article)).to be_kind_of(Article)
    end
  end

  describe '#create' do
    context 'when success' do
      let!(:user) { User.create name: 'Bruce' }
      let(:params) { { article: { title: 'First article' } } }

      before { post :create, params: params }

      it 'should create new user for article' do
        expect(assigns(:article).reload.user).to eq(User.last)
        expect(assigns(:article).reload.user).not_to eq(user)
      end

      context 'when user passed' do
        let(:params) { { article: { title: 'First article', user_id: user.id } } }

        it 'should use user from params' do
          expect(assigns(:article).reload.user).to eq(user)
        end
      end
    end
  end

  describe '#update' do
    let(:article_1) { Article.create title: 'First article' }

    context 'when success' do
      let!(:user) { User.create name: 'Bruce' }
      let(:params) { { title: 'First article - new name' } }

      before { put :update, params: { id: article_1.id, article: params } }

      it 'should create new user for article' do
        expect(assigns(:article).reload.user).to eq(User.last)
        expect(assigns(:article).reload.user).not_to eq(user)
      end

      context 'when user passed' do
        let(:params) { { title: 'First article - new name', user_id: user.id } }

        it 'should use user from params' do
          expect(assigns(:article).reload.user).to eq(user)
        end
      end
    end
  end
end
