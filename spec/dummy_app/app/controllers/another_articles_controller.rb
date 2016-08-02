class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_class 'Article'

  private

  def after_save_redirect_path
    admin_articles_path
  end
  alias :after_destroy_redirect_path :after_save_redirect_path

  def after_save_messages
    { notice: 'Saved!' }
  end

  def permitted_params
    params.require(:article).permit(:title)
  end
end
