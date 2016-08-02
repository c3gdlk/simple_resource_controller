require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe '#index' do
    let!(:user_1) { User.create name: 'Bob' }
    let!(:user_2) { User.create name: 'Rob' }
    let!(:user_3) { User.create name: 'Tom' }

    before { get :index }

    it 'should return paginated collection' do
      expect(response).to render_template(:index)
      expect(assigns(:users).to_a).to eq [user_1, user_2]
    end
  end

  it 'should not respond to not specified actions' do
    expect { get :new }.to raise_error(AbstractController::ActionNotFound)
  end
end
