# This controller was added to test the activemodel serializer integration

class Api::SomeArticlesController < ApplicationController
  include ActiveModel::Serialization

  respond_to :json

  resource_api activemodel_serializer: { resource_serializer: AnotherArticleSerializer, error_serializer: MyErrorSerializer }
  resource_actions :crud
  resource_class 'Article'

  def index2
    index! each_serializer: SomeArticleSerializer
  end

  def show2
    show! serializer: SomeArticleSerializer
  end

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
