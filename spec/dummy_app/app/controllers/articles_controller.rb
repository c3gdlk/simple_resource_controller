class ArticlesController < BaseController
  resource_actions :show
  resource_context :current_user

  has_scope :recent, type: :boolean

  private

  def after_save_redirect_path
    articles_path
  end
  alias :after_destroy_redirect_path :after_save_redirect_path

  def after_create_messages
    { notice: 'A new article was created' }
  end

  def after_update_messages
    { notice: 'Article was updated' }
  end

  def after_destroy_messages
    { danger: 'Article was removed' }
  end

  def permitted_params
    params.require(:article).permit(:title)
  end
end
