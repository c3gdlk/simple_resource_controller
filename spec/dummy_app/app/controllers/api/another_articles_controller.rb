# This controller was added to test the activemodel serializer integration

class Api::AnotherArticlesController < ApplicationController
  include ActiveModel::Serialization

  respond_to :json

  resource_actions :crud
  resource_class 'Article'
  resource_api activemodel_serializer: { error_serializer: MyErrorSerializer }

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
