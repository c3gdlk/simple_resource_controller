class AdminArticlesController < BaseController
  resource_actions :show
  resource_class 'Article'

  private

  def after_save_redirect_path
    edit_admin_article_path(resource)
  end

  def after_destroy_redirect_path
    admin_articles_path
  end

  def after_save_messages
    { notice: 'Saved!' }
  end

  def permitted_params
    params.require(:article).permit(:title)
  end
end
