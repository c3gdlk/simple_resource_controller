require 'rails_helper'

RSpec.describe PostCommentsController, type: :controller do
  describe '#index' do
    it 'should raise exception about undefied context method' do
      expect { get :index, article_id: 666 }.to raise_error(RuntimeError, 'Undefined context method post')
    end

    it 'should rase exception when can not find class by param name' do
      expect { get :index, post_id: 666 }.to raise_error(RuntimeError, 'Could not find model Post by param post_id')
    end
  end
end
