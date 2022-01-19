# This controller was added to test the jbuilder integration

class Api::ArticlesController < ApplicationController
  respond_to :json
  resource_actions :crud
  resource_api jbuilder: true

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
